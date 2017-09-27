# Dependency management

-   Prefer `require` to `before`.
-   Do not use `->` and `~>`, use `require`, `notify` or `subscribe`
    instead.
-   *Never* use `<-` or `<~`. (Lint will stop you, anyway.)
-   Don't break encapsulation. In particular, a resource within one module
    should not create a dependency (require or notify) to a resource deep within
    another. For example, `File[/etc/nginx/sites-available/foo]` from module
    `foo` should *not* directly notify `Service[nginx]` in module `nginx`.
    Instead consider these options:
  -   use the anchor pattern to ensure dependencies are passed up and down
      the include hierarchy correctly, and specify the dependency at the
      top level. In our example, this means we would have:

        ```
        class {'foo': notify => Class['nginx']}
        class {'nginx':}
        ```

  -   create a defined type within one module which other modules can use
      which will set up the correct dependencies. See `nginx::config::site`
      for an example -- this is a defined type which allows other modules
      to create an nginx configuration and will make sure it happens after
      `nginx::package` and before `nginx::service`, without the other module
      even knowing the existence of these classes.
-   When a class includes or instantiates another class, consider
    whether you need to use the anchor pattern (see below). In
    particular, for a top-level class `foo` which includes
    `foo::package`, `foo::config` and `foo::service`, *definitely* use
    the anchor pattern.

## Anchor pattern example

The problem:

Suppose I have an nginx class, which installs nginx and starts it
running. We want to ensure logstash is running before nginx, so that
we catch all of the log files. We also want to run some smoke tests
every time nginx is restarted. You might expect this to work out of
the box:

    class {'nginx':
        require => Class['logstash'],
        notify  => Class['smoke-tests'],
    }

But by default this will not do what you want, because Puppet
dependencies between classes don't work the obvious way. If the
`nginx` class includes `nginx::package`, `nginx::config`, and
`nginx::service`, then these classes will not inherit the `require`
and `notify` directives we have specified, and so we have no guarantee
that nginx will be installed after logstash, and that smoke tests will
be run after nginx is restarted.

What we have to do to get this to work is to use the anchor pattern
within the nginx class, something like this:

    class nginx {
        anchor {'nginx::begin':
            notify => Class['nginx::service']
        }

        class {'nginx::package':
            require => Anchor['nginx::begin']
        }

        class {'nginx::config':
            require => Class['nginx::package']
            notify  => Class['nginx::service']
        }

        class {'nginx::service':
            notify => Anchor['nginx::end']
        }

        anchor {'nginx::end':
        }
    }

Now, when you specify at the top that the `nginx` class `require`s the
`logstash` class, this relationship is inherited by the anchors
because they are first-class resources and not merely classes. So
`Anchor[nginx-begin]` and `Anchor[nginx-end]` both require
`Class[logstash]`. We then use all of the other relationships within
the class to ensure the dependencies are passed on correctly. In this
case, we can be sure that `Class[nginx::package]` is installed after
`Class[logstash]` because `Class[nginx::package]` requires
`Anchor[nginx::begin]` which in turn requires `Class[logstash]`.

Similarly, we can be sure that the smoke tests will run after nginx is
restarted because `Class[nginx::service]` notifies
`Anchor[nginx::end]`, which in turn notifies `Class[smoke-tests]`.

Without the anchors, the relationships specified on `Class[nginx]`
would simply not be passed on to the included classes such as
`Class[nginx::package]`.

More information on the anchor pattern can be found on
[the Puppet wiki](http://projects.puppetlabs.com/projects/puppet/wiki/Anchor_Pattern).

(NB the anchor type in puppetstdlib
[does not propagate refresh events](http://projects.puppetlabs.com/issues/12510),
so that the notify example above will fail. We have our own anchor
type in puppet/modules/anchor, which fixes this bug.)
