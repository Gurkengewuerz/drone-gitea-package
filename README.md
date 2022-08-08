# drone-gitea-package

---

A Drone plugin for uploading files as generic package to Gitea package registry. 


### Example

```yaml
pipeline:
  build:
    image: alpine
    commands:
      - touch example.md
      
  artifacts:
    image: gurken2108/drone-gitea-package
    settings:
      user:
        from_secret: gitea_user
      token:
        from_secret: gitea_token
      file: ./example.md
      version: dev
```
