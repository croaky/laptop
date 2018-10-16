# Monorepo

A monorepo structure for code organization
can afford a software development workflow that feels great.

The following is a hypothetical example
of how one monorepo could begin and evolve.
It is based on my experience at [Chain] (now [Interstellar]).

[Chain]: https://chain.com
[Interstellar]: https://interstellar.com

## Mentality

Imagine you and I have started an organization together.

We expect to write software to support the organization,
and for that software to take the shape of multiple programs.

We intend to work incrementally,
to choose technologies that we ejoy and are suited to their tasks,
and to be unafraid to build bespoke software
to improve our happiness and productivity.

## New repo

We initialize a monorepo on GitHub: `org/repo`:

```
.
└── README.md
```

## Initial design

We [design] an initial architecture like this:

[design]: https://github.com/statusok/statusok/blob/master/books/sw-design.md

* a web interface for customers, written in React
* SDKs for customers, written in Go, JavaScript, and Ruby
* an internal HTTP API used by the web interface and SDKs, written in Go
* a Postgres database backing the HTTP API

The monorepo's file structure evolves to:

```
.
├── README.md
├── Procfile
├── client
├── cmd
│   └── serverd
│       └── main.go
├── sdk
│   ├── go
│   ├── js
│   └── ruby
└── server
    └── http_handler.go
```

## Infra

Our software can only be fully realized once it is in our customers' hands.
We decide to concentrate on Amazon Web Services (AWS) for most things:

* EC2 for the HTTP API
* ELB for load balancing
* RDS for the Postgres database
* Parameter Store for environmental config
* SES for email delivery
* Cloudfront for static assets
* Route 53 for DNS

We add an `infra` directory
that begins to fill with [Terraform], `systemd`, and `bash` files:

[Terraform]: https://www.terraform.io/

```
.
├── README.md
├── Procfile
├── client
├── cmd
│   └── serverd
│       └── main.go
├── infra
├── sdk
│   ├── go
│   ├── js
│   └── ruby
└── server
    └── http_handler.go
```

## CI

We know we'll
