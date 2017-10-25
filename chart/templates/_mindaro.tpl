{{/* vim: set filetype=mustache: */}}

{{/*
Inject the Mindaro volumes.
*/}}
{{- define "mindaro.pod.volumes" -}}
{{- if .Values.development.enabled -}}
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
{{- if .Values.development.enabled -}}
        - name: mindaro-init
          image: stephpr/mindaro-init
          imagePullPolicy: Always
          securityContext:
            capabilities:
              add:
              - "NET_ADMIN"
          env:
            - name: POD_BASELINE_NAMESPACE
              value: {{ .Values.development.baseline }}
        - name: mindaro-build
          image: docker
          volumeMounts:
          - name: mindaro-docker-socket
            mountPath: /var/run/docker.sock
          - name: mindaro-source
            subPath: {{ .Release.Namespace }}/{{ .Chart.Name }}
            mountPath: /src
          workingDir: /src
          args: ["build", "-f", ".mindaro/Dockerfile", "-t", "{{ .Values.image.repository }}:{{ .Values.image.tag }}", "."]
{{- end -}}
{{- end -}}

{{/*
Inject the Mindaro containers.
*/}}
{{- define "mindaro.pod.containers" -}}
{{- if .Values.development.enabled -}}
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
            subPath: {{ .Release.Namespace }}/{{ .Chart.Name }}
            mountPath: /src
          workingDir: /src
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
{{- end -}}
{{- end -}}
