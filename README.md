# Module for create customprometheusrule with cue

## Example
See ./values/teamA

## Usage
Clone repo

Write rules with cuelang and sloth

For sloth specs
```bash
cue cmd -t env=${ENV} sloth
```
For alers
```bash
cue cmd -t env=${ENV} alerts
```

Apply manifest on cluster
```bash
kubectl apply -f ./_gen/
```

## TODO
