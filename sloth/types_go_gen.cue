// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/slok/sloth/pkg/kubernetes/api/sloth/v1

package sloth

#SlothManifest: {
	apiVersion: "sloth.slok.dev/v1"
	kind: "PrometheusServiceLevel"
	metadata: {
		name: string
		namespace: string
	}
	#PrometheusServiceLevel
}

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="SERVICE",type="string",JSONPath=".spec.service"
// +kubebuilder:printcolumn:name="DESIRED SLOs",type="integer",JSONPath=".status.processedSLOs"
// +kubebuilder:printcolumn:name="READY SLOs",type="integer",JSONPath=".status.promOpRulesGeneratedSLOs"
// +kubebuilder:printcolumn:name="GEN OK",type="boolean",JSONPath=".status.promOpRulesGenerated"
// +kubebuilder:printcolumn:name="GEN AGE",type="date",JSONPath=".status.lastPromOpRulesSuccessfulGenerated"
// +kubebuilder:printcolumn:name="AGE",type="date",JSONPath=".metadata.creationTimestamp"
// +kubebuilder:resource:singular=prometheusservicelevel,path=prometheusservicelevels,shortName=psl;pslo,scope=Namespaced,categories=slo;slos;sli;slis
//
// PrometheusServiceLevel is the expected service quality level using Prometheus
// as the backend used by Sloth.
#PrometheusServiceLevel: {
	spec?:   #PrometheusServiceLevelSpec   @go(Spec)
	// status?: #PrometheusServiceLevelStatus @go(Status)
}

// ServiceLevelSpec is the spec for a PrometheusServiceLevel.
#PrometheusServiceLevelSpec: {
	// +kubebuilder:validation:Required
	//
	// Service is the application of the SLOs.
	service: string @go(Service)

	// Labels are the Prometheus labels that will have all the recording
	// and alerting rules generated for the service SLOs.
	// REWORK for deckhouse
	labels: {
		prometheus: "main"
        component: "rules"
	} & {[string]: string} @go(Labels,map[string]string)

	// +kubebuilder:validation:MinItems=1
	//
	// SLOs are the SLOs of the service.
	slos?: [...#SLO] @go(SLOs,[]SLO)
}

// SLO is the configuration/declaration of the service level objective of
// a service.
#SLO: {
	// +kubebuilder:validation:Required
	// +kubebuilder:validation:MaxLength=128
	//
	// Name is the name of the SLO.
	name: string @go(Name)

	// Description is the description of the SLO.
	// +optional
	description?: string @go(Description)

	// +kubebuilder:validation:Required
	//
	// Objective is target of the SLO the percentage (0, 100] (e.g 99.9).
	objective: float64 @go(Objective)

	// Labels are the Prometheus labels that will have all the recording and
	// alerting rules for this specific SLO. These labels are merged with the
	// previous level labels.
	// +optional
	labels?: {[string]: string} @go(Labels,map[string]string)

	// +kubebuilder:validation:Required
	//
	// SLI is the indicator (service level indicator) for this specific SLO.
	sli: #SLI @go(SLI)

	// +kubebuilder:validation:Required
	//
	// Alerting is the configuration with all the things related with the SLO
	// alerts.
	alerting: #Alerting @go(Alerting)
}

// SLI will tell what is good or bad for the SLO.
// All SLIs will be get based on time windows, that's why Sloth needs the queries to
// use `{{.window}}` template variable.
//
// Only one of the SLI types can be used.
#SLI: {
	// Raw is the raw SLI type.
	// +optional
	raw?: null | #SLIRaw @go(Raw,*SLIRaw)

	// Events is the events SLI type.
	// +optional
	events?: null | #SLIEvents @go(Events,*SLIEvents)

	// Plugin is the pluggable SLI type.
	// +optional
	plugin?: null | #SLIPlugin @go(Plugin,*SLIPlugin)
}

// SLIRaw is a error ratio SLI already calculated. Normally this will be used when the SLI
// is already calculated by other recording rule, system...
#SLIRaw: {
	// ErrorRatioQuery is a Prometheus query that will get the raw error ratio (0-1) for the SLO.
	errorRatioQuery: string @go(ErrorRatioQuery)
}

// SLIEvents is an SLI that is calculated as the division of bad events and total events, giving
// a ratio SLI. Normally this is the most common ratio type.
#SLIEvents: {
	// ErrorQuery is a Prometheus query that will get the number/count of events
	// that we consider that are bad for the SLO (e.g "http 5xx", "latency > 250ms"...).
	// Requires the usage of `{{.window}}` template variable.
	errorQuery: string @go(ErrorQuery)

	// TotalQuery is a Prometheus query that will get the total number/count of events
	// for the SLO (e.g "all http requests"...).
	// Requires the usage of `{{.window}}` template variable.
	totalQuery: string @go(TotalQuery)
}

// SLIPlugin will use the SLI returned by the SLI plugin selected along with the options.
#SLIPlugin: {
	// Name is the name of the plugin that needs to load.
	id: string @go(ID)

	// Options are the options used for the plugin.
	// +optional
	options?: {[string]: string} @go(Options,map[string]string)
}

// Alerting wraps all the configuration required by the SLO alerts.
#Alerting: {
	// Name is the name used by the alerts generated for this SLO.
	// +optional
	name?: string @go(Name)

	// Labels are the Prometheus labels that will have all the alerts generated by this SLO.
	// +optional
	labels?: {[string]: string} @go(Labels,map[string]string)

	// Annotations are the Prometheus annotations that will have all the alerts generated by
	// this SLO.
	// +optional
	annotations?: {[string]: string} @go(Annotations,map[string]string)

	// Page alert refers to the critical alert (check multiwindow-multiburn alerts).
	pageAlert?: #Alert @go(PageAlert)

	// TicketAlert alert refers to the warning alert (check multiwindow-multiburn alerts).
	ticketAlert?: #Alert @go(TicketAlert)
}

// Alert configures specific SLO alert.
#Alert: {
	// Disable disables the alert and makes Sloth not generating this alert. This
	// can be helpful for example to disable ticket(warning) alerts.
	disable?: bool @go(Disable)

	// Labels are the Prometheus labels for the specific alert. For example can be
	// useful to route the Page alert to specific Slack channel.
	// +optional
	labels?: {[string]: string} @go(Labels,map[string]string)

	// Annotations are the Prometheus annotations for the specific alert.
	// +optional
	annotations?: {[string]: string} @go(Annotations,map[string]string)
}

// #PrometheusServiceLevelStatus: {
	// PromOpRulesGeneratedSLOs tells how many SLOs have been processed and generated for Prometheus operator successfully.
	// promOpRulesGeneratedSLOs: int @go(PromOpRulesGeneratedSLOs)

	// ProcessedSLOs tells how many SLOs haven been processed for Prometheus operator.
	// processedSLOs: int @go(ProcessedSLOs)

	// PromOpRulesGenerated tells if the rules for prometheus operator CRD have been generated.
	// promOpRulesGenerated: bool @go(PromOpRulesGenerated)

	// ObservedGeneration tells the generation was acted on, normally this is required to stop an
	// infinite loop when the status is updated because it sends a watch updated event to the watchers
	// of the K8s object.
	// observedGeneration: int64 @go(ObservedGeneration)
// }

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
//
// PrometheusServiceLevelList is a list of PrometheusServiceLevel resources.
#PrometheusServiceLevelList: {
	items: [...#PrometheusServiceLevel] @go(Items,[]PrometheusServiceLevel)
}
