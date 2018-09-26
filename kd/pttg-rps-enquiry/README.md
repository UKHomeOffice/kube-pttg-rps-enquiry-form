## Secrets
### Notify credentials
The `notify-credentials` secret should have a property of `api-key`.
### Redis
Passwords for Redis are automatically generated on initial deploy by `kd`; see
`redis/secret.yaml`.
### Basic auth credentials
```bash
htpasswd -c -b auth AzureDiamond Hunter2
kubebctl create secret generic basic-auth --from-file=auth
```
