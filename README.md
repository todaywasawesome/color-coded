# Color Coded - Istio + Helm + Codefresh Demo App

<img src="https://codefresh.io/wp-content/uploads/2018/06/Color-coded.svg" width="200px">

## What's in the app?
A simple go app that displays a color and dies when you navigate to /die. The whole thing is packaged as a Helm chart and includes a Codefresh pipeline, and Istio configuration. 

## Installation and usage
Some effort will be requried to streamline the setup for testing but it's possible now. 

1. Create a free Codefresh account
2. Fork and add this repo to Codefresh and start with a Codefresh YAML '.codefresh/helm-canary.yml' 

<A href="https://gph.is/2N4rxOz"><img src="https://media.giphy.com/media/Mn6bU0nHk8YW8ENdEB/giphy.gif" width="400"></a>
3. Set the environmental variables
4. <a href="https://g.codefresh.io/account-conf/integration/kubernetes">Add a Kubernetes cluster</a> to your Codefresh account. 
5. Install <a href="https://istio.io/docs/setup/kubernetes/quick-start/">Istio</a> and <a href="https://github.com/kubernetes/helm">Helm</a>
6. Update DNS with your <a href="https://istio.io/docs/tasks/traffic-management/ingress/#determining-the-ingress-ip-and-ports-for-a-load-balancer-ingress-gateway">Istio gateway IP address</a>.
7. Update and deploy the istio gateway configuration under istio/canary
8. Update the base canary configuration under istio/canary.yml with your app info.
9. Install the Helm package once manually (pull this repo, run a helm install)
10. Review the Codefresh yml and update any remaining variables (like Kubernetes context)
11. Deploy!

## Improve the setup experience
A lot of work could be done to streamline this setup flow. Contributors welcome!

## More about Codefresh
Goto https://codefresh.io to learn more about <a href="https://codefresh.io">Kubernetes CI/CD</a>