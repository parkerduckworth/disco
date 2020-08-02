# Disco

Stupid simple resource discovery lib for distributed Elixir applications

### About

Async discovery based on the notion of "I'll show you mine if you show me yours".  Each node publishes its local resource(s) and subscribes to one or more target capabilities.

## Installation

Add this to your `mix.exs`:

```elixir
def application do
  ...
  extra_applications: [:disco]
  ...
end

def deps do
  [
    ...
    {:disco, git: "https://github.com/parkerduckworth/disco"}
    ...
  ]
end
```

## Usage

Incoming...