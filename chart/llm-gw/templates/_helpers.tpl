{{- define "llm-gw.imagePullSecrets" -}}
{{- if .Values.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Return the proper Drupal image name
*/}}
{{- define "llm-gw.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}
