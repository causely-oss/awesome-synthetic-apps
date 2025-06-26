# Awesome Demo & Synthetic Apps

A curated collection of demo applications, synthetic data generators, and sample data sets for testing, demonstration, and development purposes. Perfect for engineers, QA teams, sales engineers, and developer relations professionals who need realistic applications and data to showcase their tools and platforms.

## Contents

- [Demo Applications](#demo-applications)
  - [Microservices & Distributed Systems](#microservices--distributed-systems)
  - [Application Simulators](#application-simulators)
- [Synthetic Data Generators](#synthetic-data-generators)
- [Sample Data Sets](#sample-data-sets)

## Demo Applications

### Microservices & Distributed Systems

A collection of demo applications that showcase microservices architectures, distributed systems patterns, and modern cloud-native development practices.

**When to use**: If you are looking for an environment that is closest to a real production system, these demo environments are optimal for you.

- [bank of anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos) -  Retail banking sample application showcasing Kubernetes and Google Cloud.
- [microservices-demo](GoogleCloudPlatform/microservices-demo) - Sample cloud-first application with 10 microservices showcasing Kubernetes, Istio, and gRPC.
- [OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo) - A microservice-based distributed system demonstrating OpenTelemetry implementation in a near real-world environment.
- [Podtato Head](https://github.com/podtato-head/podtato-head) - A microservices demo application with multiple implementations and deployment options.
- [RealWorld](https://github.com/gothinkster/realworld) - A collection of full-stack applications demonstrating different frameworks and technologies.
- [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) - A sample Spring-based application that demonstrates best practices for building web applications.
- [The New Stack (TNS) observability app](https://github.com/grafana/tns) - A simple three-tier demo application, fully instrumented with the 3 pillars of observability: metrics, logs, and traces.


### Application Simulators

Applications that simulate real-world software behavior, traffic patterns, and user interactions without implementing any internal business logic. The applications are described with a DSL in
a configuration file.

**When to use**: If you need something that can be deployed on your machine and cluster, but is flexible in it's structure, these application simulators are for you.

- [App Simulator](https://github.com/cisco-open/app-simulator) - A tool for simulating application behavior and generating synthetic data.
- [ChaosMania](https://github.com/Causely/chaosmania) - A tool for simulating various application problems in microservices architectures running on Kubernetes.

## Synthetic Data Generators

Tools and libraries for generating synthetic application data that mimics real-world patterns and behaviors.

**When to use**: If you only care about the data that is generated and send to your analytics or observability platform, these synthetic data generators are for you.

- [otelgen](https://github.com/krzko/otelgen) - A tool to generate synthetic OpenTelemetry logs, metrics and traces using OTLP (gRPC and HTTP).
- [Mustermann](https://github.com/schultyy/mustermann) - A tool that generates test data for OpenTelemetry pipelines using a custom virtual machine.
- [Telemetry generator for OpenTelemetry](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/telemetrygen) - This utility simulates a client generating traces, metrics, and logs. It is useful for testing and demonstration purposes.
- [Test Telemetry Generator](https://github.com/cisco-open/test-telemetry-generator) - A tool for generating synthetic telemetry data for testing and demonstration.
- [Trace Simulation Receiver](https://github.com/k4ji/tracesimulationreceiver) - A tool for simulating and generating trace data in various formats.


## Sample Data Sets

_Coming soon - This section will include links to sample data sets that can be used for testing and demonstration purposes._

## Contributing

Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting your contribution. We welcome all contributions that help make this collection more useful for the community!
