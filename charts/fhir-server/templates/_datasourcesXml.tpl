{{/* vim: set filetype=mustache: */}}
{{/*
The datasource.xml file for a Postgres DB.
*/}}
{{- define "defaultPostgresDatasources" }}
    <server>
        <!-- ============================================================== -->
        <!-- TENANT: default; DSID: default; TYPE: read-write               -->
        <!-- ============================================================== -->
        <dataSource id="fhirDefaultDefault" jndiName="jdbc/fhir_default_default" type="javax.sql.XADataSource" statementCacheSize="200" syncQueryTimeoutWithTransactionTimeout="true" validationTimeout="30s">
            <jdbcDriver javax.sql.XADataSource="org.postgresql.xa.PGXADataSource" libraryRef="sharedLibPostgres"/>
            <properties.postgresql
                serverName="${env.FHIR_DB_HOSTNAME}"
                portNumber="${env.FHIR_DB_PORT}"
                {{- if .Values.db.enableTls }}
                ssl="true"
                sslmode="verify-full"
                sslrootcert="{{ .Values.db.certPath }}"
                {{- end }}
                databaseName="${env.FHIR_DB_NAME}"
                user="${env.FHIR_DB_USER}"
                password="${env.FHIR_DB_PASSWORD}"
                currentSchema="${env.FHIR_DB_SCHEMA}"
            />
            <connectionManager
                minPoolSize="${env.DS_MIN_POOL_SIZE}"
                maxPoolSize="${env.DS_MAX_POOL_SIZE}"
                agedTimeout="${env.DS_AGED_TIMEOUT}"
                connectionTimeout="60s"
                maxIdleTime="2m"
            />
        </dataSource>

        {{- if .Values.objectStorage.enabled }}
        <featureManager>
            <feature>batch-1.0</feature>
            <feature>batchManagement-1.0</feature>
        </featureManager>

        <dataSource id="fhirbatchDS" jndiName="jdbc/fhirbatchDB" type="javax.sql.XADataSource" statementCacheSize="200" syncQueryTimeoutWithTransactionTimeout="true">
            <jdbcDriver javax.sql.XADataSource="org.postgresql.xa.PGXADataSource" libraryRef="sharedLibPostgres"/>
            <properties.postgresql
                serverName="${env.BATCH_DB_HOSTNAME}"
                portNumber="${env.BATCH_DB_PORT}"
                {{- if .Values.db.enableTls }}
                ssl="true"
                sslmode="verify-full"
                sslrootcert="{{ .Values.db.certPath }}"
                {{- end }}
                databaseName="${env.BATCH_DB_NAME}"
                user="${env.BATCH_DB_USER}"
                password="${env.BATCH_DB_PASSWORD}"
            />
        </dataSource>
        {{- end }}
    </server>
{{- end }}

{{/*
The datasource.xml file for a Derby DB.
*/}}
{{- define "defaultDerbyDatasources" }}
    <server>
        <!-- ============================================================== -->
        <!-- This datasource aligns with the Apache Derby database that is  -->
        <!-- created by the ghcr.io/linuxforhealth/fhir-server BOOTSTRAP_DB process.    -->
        <!-- ============================================================== -->

        <!-- ============================================================== -->
        <!-- TENANT: default; DSID: default; TYPE: read-write               -->
        <!-- ============================================================== -->
        <dataSource id="bootstrapDefaultDefault" jndiName="jdbc/bootstrap_default_default" type="javax.sql.XADataSource" statementCacheSize="200" syncQueryTimeoutWithTransactionTimeout="true" validationTimeout="30s" isolationLevel="TRANSACTION_READ_COMMITTED">
            <jdbcDriver javax.sql.XADataSource="org.apache.derby.jdbc.EmbeddedXADataSource" libraryRef="sharedLibDerby"/>
            <properties.derby.embedded databaseName="derby/fhirDB"/>
            <connectionManager maxPoolSize="50" minPoolSize="10"/>
        </dataSource>

        {{- if .Values.objectStorage.enabled }}
        <featureManager>
            <feature>batch-1.0</feature>
            <feature>batchManagement-1.0</feature>
        </featureManager>

        <dataSource id="fhirbatchDS" jndiName="jdbc/fhirbatchDB" type="javax.sql.XADataSource" statementCacheSize="200" syncQueryTimeoutWithTransactionTimeout="true" validationTimeout="30s">
            <jdbcDriver javax.sql.XADataSource="org.apache.derby.jdbc.EmbeddedXADataSource" libraryRef="sharedLibDerby"/>
            <properties.derby.embedded databaseName="derby/fhirDB"/>
            <connectionManager maxPoolSize="50" minPoolSize="10"/>
        </dataSource>
        {{- end }}
    </server>
{{- end }}
