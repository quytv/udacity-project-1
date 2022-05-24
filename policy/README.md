# Policy

## Definition Policy
```
az policy definition create --name 'deny-tagging-policy' --description "Name of the tag, such as 'environment'"  --mode "All" --rules "
{
      \"if\": {
        \"field\": \"[concat('tags[', parameters('tagName'), ']')]\",
        \"exists\": \"false\"
      },
      \"then\": {
        \"effect\": \"deny\"
      }
    }
" --params '
      {
        "tagName": {
          "type": "String",
          "metadata": {
            "displayName": "Tag Name",
            "description": "Name of the tag, such as environment"
          }
        }
      }
    '

```

## Assignment Policy
```
az policy assignment create --name 'tagging-policy' --policy 'deny-tagging-policy' -p "{ \"tagName\": \
    { \"value\": \"enviroments\"  } }"

```
