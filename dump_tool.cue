package scripts

import "tool/cli"

import "tool/file"

import "tool/exec"
import "path"
import "strings"

args: {
	env: string | *"preprod" @tag(env,short=prod|preprod)
}

command: sloth: {
	// create output dir for kubectl and debug
	mkdirsloth: file.MkdirAll & {
		path: "./_sloth_raw/"
	}
	mkdirgen: file.MkdirAll & {
		path: "./_gen/"
	}

	// generate sloth manifest from cue
	list: file.Glob & {
		glob: "./values/**/**_sloth.cue"
	}
	for _, filepath in list.files {
		(filepath): {
			echo: exec.Run & {
				cmd: ["cue", "export", "./" + filepath, "--out", "yaml", "-t", "env=\(args.env)", ]
				stdout: string
			}
			write: file.Create & {
				filename: "./_sloth_raw/" + strings.Replace(path.Base(filepath), ".cue", ".yaml", -1)
				contents: echo.stdout
			}
		}
	}

	// generate customprometheusrule from sloth manifest 
	listslothraw: file.Glob & {
		glob: "./_sloth_raw/**_sloth.yaml"
	}
	for _, filepath in listslothraw.files {
		(filepath): {
			echo: exec.Run & {
				cmd: ["sloth", "generate", "-i", "./" + filepath]
				stdout: string
			}
			write: file.Create & {
				filename: "./_gen/" + path.Base(filepath)
				contents: strings.Replace(strings.Replace(echo.stdout, "apiVersion: monitoring.coreos.com/v1", "apiVersion: deckhouse.io/v1alpha1", -1), "kind: PrometheusRule", "kind: CustomPrometheusRules", -1)
			}
		}
	}
}

// TODO
command: alert: {

	list: file.Glob & {
		glob: "./values/**/**_alert.cue"
	}

	for _, filepath in list.files {
		(filepath): {
			echo: exec.Run & {
				// note the reference to ask and city here
				cmd: ["cue", "export", "./" + filepath, "--out", "yaml"]
				stdout: string
			}
			read: file.Read & {
				filename: filepath
				contents: string
			}
			print: cli.Print & {
				text: echo.stdout + "---"
			}
		}
	}
}
