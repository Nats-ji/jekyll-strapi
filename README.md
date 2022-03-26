# jekyll-strapi

## Install

Add the "jekyll-strapi" gem to your Gemfile:

```sh
gem "jekyll-strapi", github: "Nats-ji/jekyll-strapi"
```

Then add "jekyll-strapi" to your plugins in `_config.yml`:

```yml
plugins:
    - jekyll-strapi
```

## Configuration

```yaml
strapi:
    # Your API endpoint (optional, default to http://localhost:1337)
    endpoint: http://localhost:1337
    # Strapi API version
    api_version: v4
    # Collections, key is used to access in the strapi.collections
    # template variable
    collections:
        # Example for a "articles" collection
        articles:
            # Collection name (optional)
            type: article
            # Permalink used to generate the output files (eg. /articles/:id). Placeholders: (:id, :slug, :uid, :type)
            permalink: /articles/:id/
            # Optional custom query eg. ?_limit=10000&author.id=1 (optional)
            query: ?_limit=10000&author.id=1
            # Layout file for this collection
            layout: post.html
            # Generate output files or not (default: false)
            output: true
```

## Authorization

Set the api key in the `STRAPI_API_KEY` environment variable.

```sh
export STRAPI_API_KEY="your api key"
```

## Usage

This plugin provides the `strapi` template variable. This template provides access to the collections defined in the configuration.

### Using Collections

Collections are accessed by their name in `strapi.collections`. The `articles` collections is available at `strapi.collections.articles`.

To list all documents of the collection:

```html
{% for post in strapi.collections.articles %}
<article>
    <header>
        {{ post.title }}
    </header>
    <div class="body">
        {{ post.content }}
    </div>
</article>
{% endfor %}
```

v4 api has changed:

```html
{% for post in strapi.collections.articles %}
<article>
    <header>
        {{ post.attributes.title }}
    </header>
    <div class="body">
        {{ post.attributes.content }}
    </div>
</article>
{% endfor %}
```