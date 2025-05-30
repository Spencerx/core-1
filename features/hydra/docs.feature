Feature: Documentation support
  In order to build an auto-discoverable API
  As a client software developer
  I need to know Hydra specifications of objects I send and receive

  Scenario: Checks that the Link pointing to the Hydra documentation is set
    Given I send a "GET" request to "/"
    Then the header "Link" should be equal to '<http://example.com/docs.jsonld>; rel="http://www.w3.org/ns/hydra/core#apiDocumentation"'

  Scenario: Retrieve the API vocabulary
    Given I send a "GET" request to "/docs.jsonld"
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    # Context
    And the Hydra context matches the online resource "http://www.w3.org/ns/hydra/context.jsonld"
    And the JSON node "@context[1].@vocab" should be equal to "http://example.com/docs.jsonld#"
    And the JSON node "@context[1].hydra" should be equal to "http://www.w3.org/ns/hydra/core#"
    And the JSON node "@context[1].rdf" should be equal to "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    And the JSON node "@context[1].rdfs" should be equal to "http://www.w3.org/2000/01/rdf-schema#"
    And the JSON node "@context[1].xmls" should be equal to "http://www.w3.org/2001/XMLSchema#"
    And the JSON node "@context[1].owl" should be equal to "http://www.w3.org/2002/07/owl#"
    And the JSON node "@context[1].domain.@id" should be equal to "rdfs:domain"
    And the JSON node "@context[1].domain.@type" should be equal to "@id"
    And the JSON node "@context[1].range.@id" should be equal to "rdfs:range"
    And the JSON node "@context[1].range.@type" should be equal to "@id"
    And the JSON node "@context[1].subClassOf.@id" should be equal to "rdfs:subClassOf"
    And the JSON node "@context[1].subClassOf.@type" should be equal to "@id"
    # Root properties
    And the JSON node "@id" should be equal to "/docs.jsonld"
    And the JSON node "hydra:title" should be equal to "My Dummy API"
    And the JSON node "hydra:description" should contain "This is a test API."
    And the JSON node "hydra:description" should contain "Made with love"
    And the JSON node "hydra:entrypoint" should be equal to "/"
    # Supported classes
    And the Hydra class "Entrypoint" exists
    And the Hydra class "ConstraintViolation" exists
    And the Hydra class "ConstraintViolationList" exists
    And the Hydra class "CircularReference" exists
    And the Hydra class "CustomIdentifierDummy" exists
    And the Hydra class "CustomNormalizedDummy" exists
    And the Hydra class "CustomWritableIdentifierDummy" exists
    And the Hydra class "Dummy" exists
    And the Hydra class "RelatedDummy" exists
    And the Hydra class "RelationEmbedder" exists
    And the Hydra class "ThirdLevel" exists
    And the Hydra class "ParentDummy" doesn't exist
    And the Hydra class "UnknownDummy" doesn't exist
    # Doc
    And the value of the node "@id" of the Hydra class "Dummy" is "#Dummy"
    And the value of the node "@type" of the Hydra class "Dummy" is "hydra:Class"
    And the value of the node "hydra:title" of the Hydra class "Dummy" is "Dummy"
    And the value of the node "hydra:description" of the Hydra class "Dummy" is "Dummy."
    # Properties
    And "name" property is readable for Hydra class "Dummy"
    And "name" property is writable for Hydra class "Dummy"
    And "name" property is required for Hydra class "Dummy"
    And "plainPassword" property is not readable for Hydra class "User"
    And "plainPassword" property is writable for Hydra class "User"
    And "plainPassword" property is not required for Hydra class "User"
    And the value of the node "@type" of the property "name" of the Hydra class "Dummy" is "hydra:SupportedProperty"
    And the value of the node "hydra:property.@id" of the property "name" of the Hydra class "Dummy" is "https://schema.org/name"
    And the value of the node "hydra:property.@type" of the property "name" of the Hydra class "Dummy" is "rdf:Property"
    And the value of the node "hydra:property.label" of the property "name" of the Hydra class "Dummy" is "name"
    And the value of the node "hydra:property.domain" of the property "name" of the Hydra class "Dummy" is "#Dummy"
    And the value of the node "hydra:property.range" of the property "name" of the Hydra class "Dummy" is "xmls:string"
    And the value of the node "hydra:property.range" of the property "relatedDummy" of the Hydra class "Dummy" is "https://schema.org/Product"
    And the value of the node "hydra:property.owl:maxCardinality" of the property "relatedDummy" of the Hydra class "Dummy" is "1"
    And the value of the node "hydra:property.range" of the property "relatedDummies" of the Hydra class "Dummy" is "https://schema.org/Product"
    And the value of the node "hydra:title" of the property "name" of the Hydra class "Dummy" is "name"
    And the value of the node "hydra:description" of the property "name" of the Hydra class "Dummy" is "The dummy name"
    # Operations
    And the value of the node "@type" of the operation "GET" of the Hydra class "Dummy" contains "hydra:Operation"
    And the value of the node "@type" of the operation "GET" of the Hydra class "Dummy" contains "schema:FindAction"
    And the value of the node "hydra:method" of the operation "GET" of the Hydra class "Dummy" is "GET"
    And the value of the node "hydra:title" of the operation "GET" of the Hydra class "Dummy" is "getDummy"
    And the value of the node "hydra:description" of the operation "GET" of the Hydra class "Dummy" is "Retrieves a Dummy resource."
    And the value of the node "returns" of the operation "GET" of the Hydra class "Dummy" is "Dummy"
    And the value of the node "hydra:title" of the operation "PUT" of the Hydra class "Dummy" is "putDummy"
    And the value of the node "hydra:description" of the operation "PUT" of the Hydra class "Dummy" is "Replaces the Dummy resource."
    And the value of the node "hydra:description" of the operation "DELETE" of the Hydra class "Dummy" is "Deletes the Dummy resource."
    And the value of the node "hydra:title" of the operation "DELETE" of the Hydra class "Dummy" is "deleteDummy"
    And the value of the node "returns" of the operation "DELETE" of the Hydra class "Dummy" is "owl:Nothing"
    # Deprecations
    And the boolean value of the node "owl:deprecated" of the Hydra class "DeprecatedResource" is true
    And the boolean value of the node "hydra:property.owl:deprecated" of the property "deprecatedField" of the Hydra class "DeprecatedResource" is true
    And the boolean value of the node "owl:deprecated" of the property "getDeprecatedResourceCollection" of the Hydra class "Entrypoint" is true
    And the boolean value of the node "owl:deprecated" of the operation "GET" of the Hydra class "DeprecatedResource" is true
