# Production Deployment Checklist

## Pre-Deployment

- [ ] Change request is created
- [ ] Business approval is completed
- [ ] Technical approval is completed
- [ ] Deployment plan is documented
- [ ] Rollback plan is documented
- [ ] Impacted services are identified
- [ ] Dependencies are reviewed
- [ ] Monitoring dashboards are ready
- [ ] On-call support is aware
- [ ] Communication plan is prepared

## Build and Release

- [ ] Code is merged through pull request
- [ ] Required reviewers approved the PR
- [ ] Build completed successfully
- [ ] Unit tests passed
- [ ] Integration tests passed
- [ ] Security scans completed
- [ ] Artifact version is documented
- [ ] Release branch/tag is created if applicable

## Deployment

- [ ] Confirm correct environment
- [ ] Confirm correct artifact version
- [ ] Confirm deployment window
- [ ] Execute deployment
- [ ] Monitor deployment logs
- [ ] Validate application health endpoint
- [ ] Validate application functionality
- [ ] Validate logs and metrics
- [ ] Confirm no critical alerts

## Post-Deployment

- [ ] Update change request
- [ ] Notify stakeholders
- [ ] Monitor application for agreed validation period
- [ ] Document issues if any
- [ ] Close change request after validation