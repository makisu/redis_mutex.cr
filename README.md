# redis_mutex

TODO: Write a description here

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  redis_mutex:
    github: Schniz/redis_mutex.cr
```

and have Redis installed

## Usage

```crystal
require "redis_mutex"

RedisMutex::Lock.run("SOME_KEY", 2.seconds) do
  puts "This code runs and waits until unlock with maximum time of 2 seconds lock"
end
```

## Contributing

1. Fork it ( https://github.com/Schniz/redis_mutex.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Schniz](https://github.com/Schniz) Gal Schlezinger - creator, maintainer
