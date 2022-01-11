# swagger2adoc

## Prerequisites

- Java
- Saxon HE

## Configuring the source json

A parameter "source" is used to configure the source json. By default, this is set to read from the local file "quayapi.json":

```
<xsl:param name="source" select="'file:quayapi.json'"/>
```


## Default conversion


A dummy XML file is used as input, but the real content is taken from "source" parameter


```
java -jar ~/saxon/saxon-he-10.6.jar -s:dummy.xml -xsl:swagger2adoc.xslt -o:quayapi.adoc
```


## Overriding json source using local file


```
java -jar ~/saxon/saxon-he-10.6.jar -s:dummy.xml -xsl:swagger2adoc.xslt -o:quayapi-internal.adoc source=file:quayapi-internal.json
```


## Overriding json source using remote URL

```
java -jar ~/saxon/saxon-he-10.6.jar -s:dummy.xml -xsl:swagger2adoc.xslt -o:quayio.adoc source=https://quay.io/api/v1/discovery

```

```
java -jar ~/saxon/saxon-he-10.6.jar -s:dummy.xml -xsl:swagger2adoc.xslt -o:quayio-internal.adoc source=https://quay.io/api/v1/discovery?internal=true
```



## Possible error with certs with `https` source
```
Error at char 14 in expression in xsl:variable/@select on line 17 column 65 of swagger2adoc.xslt:
  FOUT1170  Failed to read input file
  https://example-registry-quay-quay-enterprise.apps.test1.quayteam.org/api/v1/discovery.
  Caused by javax.net.ssl.SSLHandshakeException: PKIX path building failed:
  sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid
  certification path to requested target. Caused by
  sun.security.validator.ValidatorException: PKIX path building failed:
  sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid
  certification path to requested target. Caused by
  sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid
  certification path to requested target
  In template rule with match="/" on line 16 of swagger2adoc.xslt
Failed to read input file https://example-registry-quay-quay-enterprise.apps.test1.quayteam.org/api/v1/discovery
```

To get around this error, use the followiing steps:

- Download cert
- Import into trust store
- Configure trust store for Java command 


### Download cert

Using your browser, dowload the untrusted cert.



### Import key


```
keytool -import -file /home/user1/certs/downloaded.cert -alias firstCA -keystore /home/user1/certs/myTrustStore
```


### Remote source with trust store

```
java  -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStore=/home/user1/certs/myTrustStore -jar -jar ~/saxon/saxon-he-10.6.jar -s:dummy.xml -xsl:swagger2adoc.xslt -o:temp1.adoc source=https://example-registry-quay-quay-enterprise.apps.test1.quayteam.org/api/v1/discovery
```










