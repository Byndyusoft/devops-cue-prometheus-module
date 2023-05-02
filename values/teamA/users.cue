package testAteam


import (
	sloth "github.com/Byndyusoft/devops-cue-prometheus-module/sloth"
)

sloth.#SlothManifest & {
	metadata: {
		name: "users-slo"
		namespace: _namespace
	}
}
_env: string @tag(env,short=prod|preprod)
_namespace: "teama-" + _env
_services: [
	{
		name: "users"
		slos: [
			{
				type: "availability"
				name: "users-availability"
				description: "users make brrr"
				objective: 99.9
				service: "users"
				method: "GET"
				uri: "/users"
				alertName: "users-HTTPErrorRate"
			}
			{
				type: "latency"
				name: "users-latency"
				description: "users-latency"
				objective: 99
				le: "0.1"
				location: "/users/(.*)"
				alertName: "HighLatencyErrorRate-users"
			}
		]
	}
]


sloth.#PrometheusServiceLevel & {
	spec: sloth.#PrometheusServiceLevelSpec & {
		for s in _services {
			service: s.name
			slos: [ 
				for slo in s.slos {
					sloth.#SLO & {
						name: slo.name
						description: slo.description
						objective: slo.objective
						labels: {
							if slo.type == "availability" {sloth.#LabelsCategoryAvailabilityBoilerplate}
							if slo.type == "latency" {sloth.#LabelsCategoryLatencyBoilerplate}
						}
						if slo.type == "latency" {
							sli: sloth.#SLI & {
								raw: sloth.#SLIRaw & { 
									errorRatioQuery: """
									1 - (
										sum(rate(ingress_nginx_detail_request_seconds_bucket{location="\(slo.location)",le="\(slo.le)",namespace=\"\(_namespace)\"}[{{.window}}]))
										/
										sum(rate(ingress_nginx_detail_request_seconds_count{location="\(slo.location)",namespace=\"\(_namespace)\"}[{{.window}}]))
									) > 0 or vector(0)
									"""
								}
							}
						}
						if slo.type == "availability" {
							sli: sloth.#SLI & {
								events: sloth.#SLIEvents & {
									errorQuery: "sum(increase(http_server_requests_seconds_count{namespace=\"\(_namespace)\", service=\"\(slo.service)\", method=\"\(slo.method)\", uri=\"\(slo.uri)\", status=~\"(5..)\"}[{{.window}}])) > 0 or vector(0)"
									totalQuery: "sum(increase(http_server_requests_seconds_count{namespace=\"\(_namespace)\", service=\"\(slo.service)\", method=\"\(slo.method)\", uri=\"\(slo.uri)\"}[{{.window}}])) > 0 or vector(1)"
								}
							}
						}
						alerting: sloth.#Alerting & {
							name: slo.alertName
							labels: {
								if slo.type == "availability" {sloth.#LabelsCategoryAvailabilityBoilerplate}
								if slo.type == "latency" {sloth.#LabelsCategoryLatencyBoilerplate}
							} & {
								app: s.name
								namespace: _namespace
							}
							pageAlert: labels: sloth.#LabelsPageAlertBoilerplate
							ticketAlert: disable: true
						}
					}
				}
			]
		}
	}
}