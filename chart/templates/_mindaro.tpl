{{/* vim: set filetype=mustache: */}}

{{/*
Inject the Mindaro volumes.
*/}}
{{- define "mindaro.pod.volumes" -}}
{{- if .Values.mindaro -}}
        - name: mindaro-docker-socket
          hostPath:
            path: /var/run/docker.sock
        - name: mindaro-source
          azureFile:
            secretName: mindaro-source
            shareName: src
            readOnly: true
{{- end -}}
{{- end -}}

{{/*
Inject the Mindaro init containers.
*/}}
{{- define "mindaro.pod.initcontainers" -}}
{{- if .Values.mindaro -}}
        - name: mindaro-build
          image: docker
          volumeMounts:
          - name: mindaro-docker-socket
            mountPath: /var/run/docker.sock
          - name: mindaro-source
            # TODO: figure out the right granularity for this
            subPath: {{ .Values.mindaro.clientID }}/{{ .Release.Namespace }}/{{ .Chart.Name }}
            mountPath: /src
          workingDir: /src
          args:
          - build
          - -f
          - .mindaro/Dockerfile
          {{- if .Values.mindaro.build.args }}
          {{- range .Values.mindaro.build.args }}
          - --build-arg
          - {{ . }}
          {{- end }}
          {{- end }}
          {{- if .Values.mindaro.build.labels }}
          {{- range $key, $value := .Values.mindaro.build.labels }}
          - --label
          - {{ $key }}={{ $value }}
          {{- end }}
          {{- end }}
          {{- if .Values.mindaro.build.target }}
          - --target
          - {{ .Values.mindaro.build.target }}
          {{- end}}
          - -t
          # TODO: use auto-generated values
          - "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          - .
        - name: mindaro-init
          image: stephpr/mindaro-init
          imagePullPolicy: Always
          securityContext:
            capabilities:
              add:
              - "NET_ADMIN"
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: BASELINE_NAMESPACE
              value: {{ .Values.mindaro.baseline }}
            - name: NON_HTTP_PORTS
              value: {{ .Values.mindaro.nonHttpPorts | toStrings | join "," | quote }}
{{- end -}}
{{- end -}}

{{/*
Inject the Mindaro containers.
*/}}
{{- define "mindaro.pod.containers" -}}
{{- if .Values.mindaro -}}
        - name: mindaro-discovery
          image: stephpr/mindaro-discovery
          imagePullPolicy: Always
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
        - name: mindaro-envoy
          image: stephpr/mindaro-envoy
          imagePullPolicy: Always
          securityContext:
            runAsUser: 1337
        - name: mindaro-sync
          image: stephpr/mindaro-sync
          imagePullPolicy: Always
          volumeMounts:
          - name: mindaro-source
            subPath: {{ .Values.mindaro.clientID }}/{{ .Release.Namespace }}/{{ .Chart.Name }}
            mountPath: /src
          workingDir: /src
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: TARGET_CONTAINER
              value: {{ .Chart.Name }} # TODO: determine after the fact
            - name: SYNC_TARGET
              value: {{ .Values.mindaro.syncTarget }}
{{- end -}}
{{- end -}}

{{/*
Inject the Mindaro pod logic.
*/}}
{{- define "mindaro.pod" -}}
{{- if .Values.mindaro -}}
      {{- if not .Values.mindaro.terminateGracefully }}
      terminationGracePeriodSeconds: 0
      {{- end }}
{{- end -}}
{{- end -}}

{{/*
Inject the Mindaro container logic.
*/}}
{{- define "mindaro.pod.container" -}}
{{- if .Values.mindaro -}}
          {{- if .Values.mindaro.entrypoint }}
          command:  {{ toJson .Values.mindaro.entrypoint }}
          {{- end }}
          {{- if .Values.mindaro.command }}
          args:  {{ toJson .Values.mindaro.command }}
          {{- end }}
{{- end -}}
{{- end -}}
