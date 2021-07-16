# Convenia Bot
This bot receives webhooks from [Convenia](https://www.convenia.com.br) and post them to Slack.
It also uses Quantum to perform periodic checks on Convenia's employee base and post them to Slack

## How it works
You can create `ConveniaMsgs` that implement a `parse/1` function that patterns match to the data received by the webhook, processes it and the output should be a tuple with a `Map` and a `url` to be posted.

Currently there is a large boilerplait to be added to each `ConveniaMsgs`


```
defmodule CB.ConveniaBot.ConveniaMsgs.Admission do
  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "admission." <> _action} = data), do: unquote(__MODULE__).parse(data)
      # It pattern match to the messages passed and forward to the parse function below 
    end
  end

  # def parse(%{"type" => "admission." <> _action} = data) do
  def parse(data) do
    # Add formating logic here
  end
end

```

In the `convenia_msgs.ex` you should _register_ the action by _using_ the module.
```
defmodule CB.ConveniaBot.ConveniaMsgs do
  use CB.ConveniaBot.ConveniaMsgs.Admission
  # ...

end
```

## Webhook address
The webhook address to be registered in convenia depends on the `SECRET_USER` `SECRET_PASS` defined in the environment:
`https://{server}/api/:SECRET_USER/:SECRET_PASS`

If `SECRET_USER` is `a` and `SECRET_PASS` is `1234` the url is
`https://{server}/api/a/1234`



## Employee GenServer

It will start with the server, fetch all employees `/api/v3/employees` and enrich each employee data on the `/api/v3/employees/{employeeId}` endpoint.
You can add custom actions such as the `admissions ahead` that will be triggered by Quantum and generate a post.



## Convenia Resources
API: https://public-api.convenia.com.br/
Webhook: https://public-api.convenia.com.br/webhooks

## Slack resources
Slack Kit Builder https://app.slack.com/block-kit-builder/

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

You need to provide the following Environment variables.

`SLACK_URL`
`INFRA_INTERNA_SLACK_URL`
`CONVENIA_TOKEN`
`SECRET_USER`
`SECRET_PASS`

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

It works out of the box on [Gigalixir](https://www.gigalixir.com/)

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
