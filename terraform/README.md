# Terraform: www.shaunchopra.com hosting

Infrastructure as code for the static portfolio site: a private S3 bucket served
through CloudFront (OAC), with an ACM certificate and Route 53 alias records.
Everything here was originally created by hand in the console and then **imported**
(see `imports.tf`). Nothing was recreated.

## Layout

| Path | Purpose |
| --- | --- |
| `bootstrap/` | One-off config (local state) that creates the remote-state bucket |
| `versions.tf` | Terraform/provider pins and the S3 backend (native lockfile) |
| `providers.tf` | `aws` (ap-southeast-2) and `aws.us_east_1` (ACM for CloudFront) |
| `variables.tf` / `outputs.tf` | Inputs (all defaulted) and outputs |
| `s3.tf` | Site bucket, ownership, public-access block, encryption, OAC bucket policy |
| `cloudfront.tf` | OAC, distribution, viewer-request function, security headers, error pages |
| `functions/viewer-request.js` | CloudFront Function source |
| `acm.tf` | Certificate (us-east-1) and its validation |
| `dns.tf` | Apex/www A+AAAA aliases and ACM validation CNAMEs |
| `github_oidc.tf` | GitHub Actions OIDC provider and deploy role |
| `imports.tf` | `import {}` blocks used to adopt the existing resources |

## What's managed

- **S3** `shaunchopra-portfolio` (ap-southeast-2): bucket, BucketOwnerEnforced ownership,
  full public-access block, SSE-S3 (AES256, bucket key, SSE-C blocked), and the bucket
  policy that allows only this distribution (via OAC) to `s3:GetObject`.
- **CloudFront** `E1I2IQ66RCXLWJ` (aliases `shaunchopra.com`, `www.shaunchopra.com`) and
  its OAC `E200YBENURIN4A`. It uses the AWS-managed `Managed-CachingOptimized` cache policy.
- **CloudFront Function** `shaunchopra-portfolio-viewer-request` (cloudfront-js-2.0, viewer-request):
  - 301 `shaunchopra.com/*` -> `https://www.shaunchopra.com/*` (path + query string kept), so
    www is the canonical host;
  - directory-style URLs for Astro `build.format: 'directory'`: `/foo/` and `/foo` serve
    `/foo/index.html`; paths whose last segment contains a `.` are left as they are.
- **Custom error responses**: S3 403 (missing key on a private bucket) and 404 are served as
  `/404.html` with HTTP 404 (error-caching TTL 60s). The site build must publish `404.html`
  at the bucket root.
- **Security headers**: the AWS-managed `Managed-SecurityHeadersPolicy` (HSTS 1 year without
  includeSubDomains, `nosniff`, `X-Frame-Options: SAMEORIGIN`,
  `Referrer-Policy: strict-origin-when-cross-origin`, `X-XSS-Protection`). It only adds headers,
  so the `x-cache` and `x-amz-cf-pop` headers the site's JS reads are still sent. Turn it off with
  `enable_security_headers = false`.
- **ACM** certificate for `shaunchopra.com` and `www.shaunchopra.com` (us-east-1, DNS-validated).
- **Route 53** (zone `Z03490663UEOG1HXQIAW6`): A and AAAA alias records for the apex and www,
  plus the two ACM validation CNAMEs.
- **GitHub OIDC**: the `token.actions.githubusercontent.com` provider and the IAM role
  `shaunchopra-portfolio-github-deploy`.

Key resources have `prevent_destroy` set (bucket, distribution, certificate).

## Not managed here (on purpose)

- **The hosted zone itself, its NS/SOA, and unrelated records**: SES DKIM CNAMEs, `_dmarc`,
  `test.shaunchopra.com`, and anything else in the zone. The zone was created by the
  Route 53 Registrar and is referenced by ID (`var.hosted_zone_id`).
- **The WAF web ACL** `CreatedByCloudFront-adc39c39` (us-east-1), created by the console.
  The distribution keeps referencing it through `var.waf_web_acl_arn`, but its rules are
  not managed here.
- **The CloudFront pricing plan.** The distribution is on the **Free flat-rate plan**, which
  **rejects custom response headers policies**. That is why the managed policy is used. If you
  move to pay-as-you-go, you can switch to a custom policy (for example
  `Content-Security-Policy: frame-ancestors 'none'`).
- **Site bucket versioning.** It has never been enabled and is left as it is. Deploys go through
  `aws s3 sync`, and git history is the source of truth.
- **The `prod-/dev-canonical-host-redirect` CloudFront Functions.** They belong to the
  oj-auto-detailing distributions and are not attached to this one.
- **Site content.** Deployed by CI (`aws s3 sync` + invalidation), not by Terraform.

## Remote state

- Bucket: `shaunchopra-portfolio-tfstate-051334264317` (ap-southeast-2). It has versioning
  (noncurrent versions expire after 90 days), SSE-S3, a full public-access block,
  BucketOwnerEnforced ownership and a TLS-only bucket policy.
- Key: `site/terraform.tfstate`. Locking uses S3's native lockfile (`use_lockfile = true`,
  which writes `site/terraform.tfstate.tflock`), so there is no DynamoDB table.
  Requires Terraform >= 1.10.

### Bootstrap (one time, already done)

```sh
cd terraform/bootstrap
terraform init
terraform apply
```

`bootstrap/` uses **local** state (`bootstrap/terraform.tfstate`, gitignored). If that file
is lost, nothing breaks. To manage the bucket again, re-import it:
`terraform import aws_s3_bucket.tfstate shaunchopra-portfolio-tfstate-051334264317`
(and the same for the sub-resources).

## Usage

```sh
cd terraform
terraform init      # configures the S3 backend
terraform plan
terraform apply     # local/manual only (see below)
```

Credentials come from your normal AWS CLI profile (the account owner).

The `import {}` blocks are now no-ops because the resources are already in state. They can stay
as documentation or be deleted.

## CI/CD (GitHub Actions)

Use `terraform output github_deploy_role_arn` as `role-to-assume` in
`aws-actions/configure-aws-credentials`. The job needs `permissions: id-token: write`.

The trust policy accepts only `aud = sts.amazonaws.com` and these exact `sub` values
(`var.github_oidc_subjects`):

- `repo:shaunchopra/portfolio:ref:refs/heads/main`
- `repo:shaunchopra/portfolio:pull_request`
- `repo:shaunchopra/portfolio:environment:production`

Note: if a job declares `environment: production`, GitHub sends the `environment:` subject
rather than the `ref:` one.

Role permissions (inline policies):

- `site-deploy`: `s3:ListBucket`/`GetBucketLocation` on the site bucket;
  `s3:GetObject`/`PutObject`/`DeleteObject` on its objects; and
  `cloudfront:CreateInvalidation`/`GetInvalidation`/`ListInvalidations` on this distribution.
- `terraform-plan-readonly`: read access to the state object; read/write/delete on the
  `.tflock` object only; and read-only access to the managed resources (S3 bucket config,
  `cloudfront:Get*/List*/Describe*` (functions and policies included), ACM describe, Route 53
  zone read, and IAM read on its own role and OIDC provider).

**CI can run `terraform plan` but not `terraform apply`.** It has no write permissions on
CloudFront, ACM, Route 53 or IAM. This is intentional: infrastructure changes are applied
locally. Automated applies would need a separate, tightly scoped apply role, for example one
trusted only for the `production` environment with required reviewers.
