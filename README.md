# IntegrationArchitectureDemo
A small set of demos covering Tight-Coupling, CQRS, Event Driven, and Data Integration.

## Demo 1 - Tight-Coupling
This demo shows an application (customer address update) that is directly coupled to a set of backend services, if a backend service is slow or fails, the user is stuck waiting while the action is retried. This demo is designed to show the "before" design.

## Demo 2 - CQRS
Rather than trying to call/update all backend services as a single operation, this demo shows how to offload tasks to a queue to be processed asynchronously. This allows tasks to be retried without impacting the user experence.

## Demo 3 - Event Driven
In Demo 1 & 2 we update the backends directly from the app. This forces us to redeploy the app every time a backend needs to be added, modified, or removed. In this demo we use Service Bus to emit an event that backends can subscribe to, either directly or via a Logic App. Application Insights is used to provide obervability.

## Demo 4 - Data Integration
In this demo we take a look at alternative integration patterns for data centric workloads, using Data Factory to transform a flat file into a Data Store.