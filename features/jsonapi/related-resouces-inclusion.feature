Feature: JSON API Inclusion of Related Resources
  In order to be able to handle inclusion of related resources
  As a client software developer
  I need to be able to specify include parameters according to JSON API recommendation

  Background:
    Given I add "Accept" header equal to "application/vnd.api+json"
    And I add "Content-Type" header equal to "application/vnd.api+json"

  @createSchema
  Scenario: Request inclusion of a related resource (many to one)
    Given there are 3 dummy property objects
    When I send a "GET" request to "/dummy_properties/1?include=group"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "attributes": {
                "_id": 1,
                "foo": "Foo #1",
                "bar": "Bar #1",
                "baz": "Baz #1",
                "name_converted": "NameConverted #1"
            },
            "relationships": {
                "group": {
                    "data": {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }
                },
                "groups": {
                    "data": []
                }
            }
        },
        "included": [
            {
                "id": "/dummy_groups/1",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1",
                    "bar": "Bar #1",
                    "baz": "Baz #1"
                }
            }
        ]
    }
  """

  @createSchema
  Scenario: Request inclusion of a non existing related resource
    Given there are 3 dummy property objects
    When I send a "GET" request to "/dummy_properties/1?include=foo"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "attributes": {
                "_id": 1,
                "foo": "Foo #1",
                "bar": "Bar #1",
                "baz": "Baz #1",
                "name_converted": "NameConverted #1"
            },
            "relationships": {
                "group": {
                    "data": {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }
                },
                "groups": {
                    "data": []
                }
            }
        }
    }
  """

  @createSchema
  Scenario: Request inclusion of a related resource keeping main object properties unfiltered
    Given there are 3 dummy property objects
    When I send a "GET" request to "/dummy_properties/1?include=group&fields[group]=id,foo&fields[DummyProperty]=bar,baz"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "attributes": {
                "bar": "Bar #1",
                "baz": "Baz #1"
            },
            "relationships": {
                "group": {
                    "data": {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }
                }
            }
        },
        "included": [
            {
                "id": "/dummy_groups/1",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1"
                }
            }
        ]
    }
  """

  Scenario: Request inclusion of related resources and specific fields
    When I send a "GET" request to "/dummy_properties/1?include=group&fields[group]=id,foo"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "relationships": {
                "group": {
                    "data": {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }
                }
            }
        },
        "included": [
            {
                "id": "/dummy_groups/1",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1"
                }
            }
        ]
    }
  """

  @createSchema
  Scenario: Request inclusion of related resources (many to many)
    Given there are 1 dummy property objects with 3 groups
    When I send a "GET" request to "/dummy_properties/1?include=groups"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "attributes": {
                "_id": 1,
                "foo": "Foo #1",
                "bar": "Bar #1",
                "baz": "Baz #1",
                "name_converted": null
            },
            "relationships": {
                "group": {
                    "data": {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }
                },
                "groups": {
                    "data": [
                      {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/2"
                      },
                      {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/3"
                      },
                      {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/4"
                      }
                    ]
                }
            }
        },
        "included": [
            {
                "id": "/dummy_groups/2",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 2,
                    "foo": "Foo #11",
                    "bar": "Bar #11",
                    "baz": "Baz #11"
                }
            },
            {
                "id": "/dummy_groups/3",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 3,
                    "foo": "Foo #12",
                    "bar": "Bar #12",
                    "baz": "Baz #12"
                }
            },
            {
                "id": "/dummy_groups/4",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 4,
                    "foo": "Foo #13",
                    "bar": "Bar #13",
                    "baz": "Baz #13"
                }
            }
        ]
    }
  """

  @createSchema
  Scenario: Request inclusion of related resources (many to many and many to one)
    Given there are 1 dummy property objects with 3 groups
    When I send a "GET" request to "/dummy_properties/1?include=groups,group"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "attributes": {
                "_id": 1,
                "foo": "Foo #1",
                "bar": "Bar #1",
                "baz": "Baz #1",
                "name_converted": null
            },
            "relationships": {
                "group": {
                    "data": {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }
                },
                "groups": {
                    "data": [
                      {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/2"
                      },
                      {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/3"
                      },
                      {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/4"
                      }
                    ]
                }
            }
        },
        "included": [
            {
                "id": "/dummy_groups/1",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1",
                    "bar": "Bar #1",
                    "baz": "Baz #1"
                }
            },
            {
                "id": "/dummy_groups/2",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 2,
                    "foo": "Foo #11",
                    "bar": "Bar #11",
                    "baz": "Baz #11"
                }
            },
            {
                "id": "/dummy_groups/3",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 3,
                    "foo": "Foo #12",
                    "bar": "Bar #12",
                    "baz": "Baz #12"
                }
            },
            {
                "id": "/dummy_groups/4",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 4,
                    "foo": "Foo #13",
                    "bar": "Bar #13",
                    "baz": "Baz #13"
                }
            }
        ]
    }
  """

  @createSchema
  Scenario: Request inclusion of resource with relation
    Given there are 1 dummy objects with relatedDummy and its thirdLevel
    When I send a "GET" request to "/dummies/1?include=relatedDummy"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
        {
            "data": {
                "id": "/dummies/1",
                "type": "Dummy",
                "attributes": {
                    "description": null,
                    "dummy": null,
                    "dummyBoolean": null,
                    "dummyDate": null,
                    "dummyFloat": null,
                    "dummyPrice": null,
                    "jsonData": [],
                    "arrayData": [],
                    "name_converted": null,
                    "_id": 1,
                    "name": "Dummy #1",
                    "alias": "Alias #0",
                    "foo": null
                },
                "relationships": {
                    "relatedDummy": {
                        "data": {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/1"
                        }
                    },
                    "relatedDummies": {
                        "data": []
                    },
                    "relatedOwnedDummy": {
                        "data": []
                    },
                    "relatedOwningDummy": {
                        "data": []
                    }
                }
            },
            "included": [
                {
                    "id": "/related_dummies/1",
                    "type": "RelatedDummy",
                    "attributes": {
                        "name": "RelatedDummy #1",
                        "dummyDate": null,
                        "dummyBoolean": null,
                        "embeddedDummy": {
                            "dummyName": null,
                            "dummyBoolean": null,
                            "dummyDate": null,
                            "dummyFloat": null,
                            "dummyPrice": null,
                            "symfony": null
                        },
                        "_id": 1,
                        "symfony": "symfony",
                        "age": null
                    },
                    "relationships": {
                        "thirdLevel": {
                            "data": {
                                "type": "ThirdLevel",
                                "id": "/third_levels/1"
                            }
                        },
                        "relatedToDummyFriend": {
                            "data": []
                        }
                    }
                }
            ]
       }
    """

  @createSchema
  Scenario: Request inclusion of resources from path
    Given there is a dummy object with a fourth level relation
    When I send a "GET" request to "/dummies/1?include=relatedDummy.thirdLevel.fourthLevel"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummies/1",
            "type": "Dummy",
            "attributes": {
                "_id": 1,
                "name": "Dummy with relations",
                "alias": null,
                "foo": null,
                "description": null,
                "dummy": null,
                "dummyBoolean": null,
                "dummyDate": null,
                "dummyFloat": null,
                "dummyPrice": null,
                "jsonData": [],
                "arrayData": [],
                "name_converted": null
            },
            "relationships": {
                "relatedDummy": {
                    "data": {
                        "type": "RelatedDummy",
                        "id": "/related_dummies/1"
                    }
                },
                "relatedDummies": {
                    "data": [
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/1"
                        },
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/2"
                        }
                    ]
                },
                "relatedOwnedDummy": {
                    "data": []
                },
                "relatedOwningDummy": {
                    "data": []
                }
            }
        },
        "included": [
            {
                "id": "/related_dummies/1",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 1,
                    "name": "Hello",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/1"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/1",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 1,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": {
                            "type": "FourthLevel",
                            "id": "/fourth_levels/1"
                        }
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/1"
                            },
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/2"
                            }
                        ]
                    }
                }
            },
            {
                "id": "/fourth_levels/1",
                "type": "FourthLevel",
                "attributes": {
                    "_id": 1,
                    "level": 4
                },
                "relationships": {
                    "badThirdLevel": {
                        "data": []
                    }
                }
            }
        ]
    }
    """

  @createSchema
  Scenario: Request inclusion of resources from path with collection
    Given there is a dummy object with 3 relatedDummies and their thirdLevel
    When I send a "GET" request to "/dummies/1?include=relatedDummies.thirdLevel"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummies/1",
            "type": "Dummy",
            "attributes": {
                "_id": 1,
                "name": "Dummy with relations",
                "alias": null,
                "foo": null,
                "description": null,
                "dummy": null,
                "dummyBoolean": null,
                "dummyDate": null,
                "dummyFloat": null,
                "dummyPrice": null,
                "jsonData": [],
                "arrayData": [],
                "name_converted": null
            },
            "relationships": {
                "relatedDummy": {
                    "data": []
                },
                "relatedDummies": {
                    "data": [
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/1"
                        },
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/2"
                        },
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/3"
                        }
                    ]
                },
                "relatedOwnedDummy": {
                    "data": []
                },
                "relatedOwningDummy": {
                    "data": []
                }
            }
        },
        "included": [
            {
                "id": "/related_dummies/1",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 1,
                    "name": "RelatedDummy #1",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/1"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/1",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 1,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/1"
                            }
                        ]
                    }
                }
            },
            {
                "id": "/related_dummies/2",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 2,
                    "name": "RelatedDummy #2",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/2"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/2",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 2,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/2"
                            }
                        ]
                    }
                }
            },
            {
                "id": "/related_dummies/3",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 3,
                    "name": "RelatedDummy #3",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/3"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/3",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 3,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/3"
                            }
                        ]
                    }
                }
            }
        ]
    }
    """

  @createSchema
  Scenario: Do not include the requested resource
    Given there is a RelatedOwningDummy object with OneToOne relation
    When I send a "GET" request to "/dummies/1?include=relatedOwningDummy.ownedDummy"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummies/1",
            "type": "Dummy",
            "attributes": {
                "description": null,
                "dummy": null,
                "dummyBoolean": null,
                "dummyDate": null,
                "dummyFloat": null,
                "dummyPrice": null,
                "jsonData": [],
                "arrayData": [],
                "name_converted": null,
                "_id": 1,
                "name": "plop",
                "alias": null,
                "foo": null
            },
            "relationships": {
                "relatedDummy": {
                    "data": []
                },
                "relatedDummies": {
                    "data": []
                },
                "relatedOwnedDummy": {
                    "data": []
                },
                "relatedOwningDummy": {
                    "data": {
                        "type": "RelatedOwningDummy",
                        "id": "/related_owning_dummies/1"
                    }
                }
            }
        },
        "included": [
            {
                "id": "/related_owning_dummies/1",
                "type": "RelatedOwningDummy",
                "attributes": {
                    "name": null,
                    "_id": 1
                },
                "relationships": {
                    "ownedDummy": {
                        "data": {
                            "type": "Dummy",
                            "id": "/dummies/1"
                        }
                    }
                }
            }
        ]
   }
    """

  @createSchema
  Scenario: Do not include resources multiple times
    Given there is a dummy object with 3 relatedDummies with same thirdLevel
    When I send a "GET" request to "/dummies/1?include=relatedDummies.thirdLevel"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "data": {
            "id": "/dummies/1",
            "type": "Dummy",
            "attributes": {
                "_id": 1,
                "name": "Dummy with relations",
                "alias": null,
                "foo": null,
                "description": null,
                "dummy": null,
                "dummyBoolean": null,
                "dummyDate": null,
                "dummyFloat": null,
                "dummyPrice": null,
                "jsonData": [],
                "arrayData": [],
                "name_converted": null
            },
            "relationships": {
                "relatedDummy": {
                    "data": []
                },
                "relatedDummies": {
                    "data": [
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/1"
                        },
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/2"
                        },
                        {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/3"
                        }
                    ]
                },
                "relatedOwnedDummy": {
                    "data": []
                },
                "relatedOwningDummy": {
                    "data": []
                }
            }
        },
        "included": [
            {
                "id": "/related_dummies/1",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 1,
                    "name": "RelatedDummy #1",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/1"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/1",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 1,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/1"
                            },
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/2"
                            },
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/3"
                            }
                        ]
                    }
                }
            },
            {
                "id": "/related_dummies/2",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 2,
                    "name": "RelatedDummy #2",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/1"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/related_dummies/3",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 3,
                    "name": "RelatedDummy #3",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/1"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            }
        ]
    }
    """


  @createSchema
  Scenario: Request inclusion of a related resources on collection
    Given there are 3 dummy property objects
    When I send a "GET" request to "/dummy_properties?include=group"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "links": {
            "self": "/dummy_properties?include=group"
        },
        "meta": {
            "totalItems": 3,
            "itemsPerPage": 3,
            "currentPage": 1
        },
        "data": [
            {
                "id": "/dummy_properties/1",
                "type": "DummyProperty",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1",
                    "bar": "Bar #1",
                    "baz": "Baz #1",
                    "name_converted": "NameConverted #1"
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "DummyGroup",
                            "id": "/dummy_groups/1"
                        }
                    },
                    "groups": {
                        "data": []
                    }
                }
            },
            {
                "id": "/dummy_properties/2",
                "type": "DummyProperty",
                "attributes": {
                    "_id": 2,
                    "foo": "Foo #2",
                    "bar": "Bar #2",
                    "baz": "Baz #2",
                    "name_converted": "NameConverted #2"
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "DummyGroup",
                            "id": "/dummy_groups/2"
                        }
                    },
                    "groups": {
                        "data": []
                    }
                }
            },
            {
                "id": "/dummy_properties/3",
                "type": "DummyProperty",
                "attributes": {
                    "_id": 3,
                    "foo": "Foo #3",
                    "bar": "Bar #3",
                    "baz": "Baz #3",
                    "name_converted": "NameConverted #3"
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "DummyGroup",
                            "id": "/dummy_groups/3"
                        }
                    },
                    "groups": {
                        "data": []
                    }
                }
            }
        ],
        "included": [
            {
                "id": "/dummy_groups/1",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1",
                    "bar": "Bar #1",
                    "baz": "Baz #1"
                }
            },
            {
                "id": "/dummy_groups/2",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 2,
                    "foo": "Foo #2",
                    "bar": "Bar #2",
                    "baz": "Baz #2"
                }
            },
            {
                "id": "/dummy_groups/3",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 3,
                    "foo": "Foo #3",
                    "bar": "Bar #3",
                    "baz": "Baz #3"
                }
            }
        ]
    }
  """

  @createSchema
  Scenario: Request inclusion of a related resources on collection should not duplicated included object
    Given there are 3 dummy property objects with a shared group
    When I send a "GET" request to "/dummy_properties?include=group"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "links": {
            "self": "/dummy_properties?include=group"
        },
        "meta": {
            "totalItems": 3,
            "itemsPerPage": 3,
            "currentPage": 1
        },
        "data": [
            {
                "id": "/dummy_properties/1",
                "type": "DummyProperty",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #1",
                    "bar": "Bar #1",
                    "baz": "Baz #1",
                    "name_converted": null
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "DummyGroup",
                            "id": "/dummy_groups/1"
                        }
                    },
                    "groups": {
                        "data": []
                    }
                }
            },
            {
                "id": "/dummy_properties/2",
                "type": "DummyProperty",
                "attributes": {
                    "_id": 2,
                    "foo": "Foo #2",
                    "bar": "Bar #2",
                    "baz": "Baz #2",
                    "name_converted": null
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "DummyGroup",
                            "id": "/dummy_groups/1"
                        }
                    },
                    "groups": {
                        "data": []
                    }
                }
            },
            {
                "id": "/dummy_properties/3",
                "type": "DummyProperty",
                "attributes": {
                    "_id": 3,
                    "foo": "Foo #3",
                    "bar": "Bar #3",
                    "baz": "Baz #3",
                    "name_converted": null
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "DummyGroup",
                            "id": "/dummy_groups/1"
                        }
                    },
                    "groups": {
                        "data": []
                    }
                }
            }
        ],
        "included": [
            {
                "id": "/dummy_groups/1",
                "type": "DummyGroup",
                "attributes": {
                    "_id": 1,
                    "foo": "Foo #shared",
                    "bar": "Bar #shared",
                    "baz": "Baz #shared"
                }
            }
        ]
    }
  """

  @createSchema
  Scenario: Request inclusion of a related resources on collection should not duplicated included object
    Given there are 2 dummy property objects with different number of related groups
    When I send a "GET" request to "/dummy_properties?include=groups"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be a superset of:
    """
    {
        "links": {
            "self": "/dummy_properties?include=groups"
        },
        "meta": {
            "totalItems": 2,
            "itemsPerPage": 3,
            "currentPage": 1
        },
        "data": [{
            "id": "/dummy_properties/1",
            "type": "DummyProperty",
            "attributes": {
                "_id": 1,
                "foo": "Foo #1",
                "bar": "Bar #1",
                "baz": "Baz #1",
                "name_converted": null
            },
            "relationships": {
                "groups": {
                    "data": [{
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }]
                }
            }
        }, {
            "id": "/dummy_properties/2",
            "type": "DummyProperty",
            "attributes": {
                "_id": 2,
                "foo": "Foo #2",
                "bar": "Bar #2",
                "baz": "Baz #2",
                "name_converted": null
            },
            "relationships": {
                "groups": {
                    "data": [{
                        "type": "DummyGroup",
                        "id": "/dummy_groups/1"
                    }, {
                        "type": "DummyGroup",
                        "id": "/dummy_groups/2"
                    }]
                }
            }
        }],
        "included": [{
            "id": "/dummy_groups/1",
            "type": "DummyGroup",
            "attributes": {
                "_id": 1,
                "foo": "Foo #1",
                "bar": "Bar #1",
                "baz": "Baz #1"
            }
        }, {
            "id": "/dummy_groups/2",
            "type": "DummyGroup",
            "attributes": {
                "_id": 2,
                "foo": "Foo #2",
                "bar": "Bar #2",
                "baz": "Baz #2"
            }
        }]
    }
    """

  @createSchema
  Scenario: Request inclusion from path of resource with relation
    Given there are 3 dummy objects with relatedDummy and its thirdLevel
    When I send a "GET" request to "/dummies?include=relatedDummy.thirdLevel"
    Then the response status code should be 200
    And the response should be in JSON
    And the JSON should be valid according to the JSON API schema
    And the JSON should be equal to:
    """
    {
        "links": {
            "self": "/dummies?include=relatedDummy.thirdLevel"
        },
        "meta": {
            "totalItems": 3,
            "itemsPerPage": 3,
            "currentPage": 1
        },
        "data": [
            {
                "id": "/dummies/1",
                "type": "Dummy",
                "attributes": {
                    "_id": 1,
                    "name": "Dummy #1",
                    "alias": "Alias #2",
                    "foo": null,
                    "description": null,
                    "dummy": null,
                    "dummyBoolean": null,
                    "dummyDate": null,
                    "dummyFloat": null,
                    "dummyPrice": null,
                    "jsonData": [],
                    "arrayData": [],
                    "name_converted": null
                },
                "relationships": {
                    "relatedDummy": {
                        "data": {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/1"
                        }
                    },
                    "relatedDummies": {
                        "data": []
                    },
                    "relatedOwnedDummy": {
                        "data": []
                    },
                    "relatedOwningDummy": {
                        "data": []
                    }
                }
            },
            {
                "id": "/dummies/2",
                "type": "Dummy",
                "attributes": {
                    "_id": 2,
                    "name": "Dummy #2",
                    "alias": "Alias #1",
                    "foo": null,
                    "description": null,
                    "dummy": null,
                    "dummyBoolean": null,
                    "dummyDate": null,
                    "dummyFloat": null,
                    "dummyPrice": null,
                    "jsonData": [],
                    "arrayData": [],
                    "name_converted": null
                },
                "relationships": {
                    "relatedDummy": {
                        "data": {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/2"
                        }
                    },
                    "relatedDummies": {
                        "data": []
                    },
                    "relatedOwnedDummy": {
                        "data": []
                    },
                    "relatedOwningDummy": {
                        "data": []
                    }
                }
            },
            {
                "id": "/dummies/3",
                "type": "Dummy",
                "attributes": {
                    "_id": 3,
                    "name": "Dummy #3",
                    "alias": "Alias #0",
                    "foo": null,
                    "description": null,
                    "dummy": null,
                    "dummyBoolean": null,
                    "dummyDate": null,
                    "dummyFloat": null,
                    "dummyPrice": null,
                    "jsonData": [],
                    "arrayData": [],
                    "name_converted": null
                },
                "relationships": {
                    "relatedDummy": {
                        "data": {
                            "type": "RelatedDummy",
                            "id": "/related_dummies/3"
                        }
                    },
                    "relatedDummies": {
                        "data": []
                    },
                    "relatedOwnedDummy": {
                        "data": []
                    },
                    "relatedOwningDummy": {
                        "data": []
                    }
                }
            }
        ],
        "included": [
            {
                "id": "/related_dummies/1",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 1,
                    "name": "RelatedDummy #1",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/1"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/1",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 1,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/1"
                            }
                        ]
                    }
                }
            },
            {
                "id": "/related_dummies/2",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 2,
                    "name": "RelatedDummy #2",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/2"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/2",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 2,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/2"
                            }
                        ]
                    }
                }
            },
            {
                "id": "/related_dummies/3",
                "type": "RelatedDummy",
                "attributes": {
                    "_id": 3,
                    "name": "RelatedDummy #3",
                    "symfony": "symfony",
                    "dummyDate": null,
                    "dummyBoolean": null,
                    "embeddedDummy": {
                        "dummyName": null,
                        "dummyBoolean": null,
                        "dummyDate": null,
                        "dummyFloat": null,
                        "dummyPrice": null,
                        "symfony": null
                    },
                    "age": null
                },
                "relationships": {
                    "thirdLevel": {
                        "data": {
                            "type": "ThirdLevel",
                            "id": "/third_levels/3"
                        }
                    },
                    "relatedToDummyFriend": {
                        "data": []
                    }
                }
            },
            {
                "id": "/third_levels/3",
                "type": "ThirdLevel",
                "attributes": {
                    "_id": 3,
                    "level": 3,
                    "test": true
                },
                "relationships": {
                    "fourthLevel": {
                        "data": []
                    },
                    "badFourthLevel": {
                        "data": []
                    },
                    "relatedDummies": {
                        "data": [
                            {
                                "type": "RelatedDummy",
                                "id": "/related_dummies/3"
                            }
                        ]
                    }
                }
            }
        ]
    }
    """
