# github-project-labels

This script will __automatically update Github issue labels__ when an issue card is moved from one column of your __project board__ to the next. The issue labels must have matching names with the columns of the project for this hook to work.

See a video of the script in action: https://youtu.be/BQw7W6TZdSU (as the update requires multiple requests to Github to retrieve resources, there is a small delay before the update occurs after moving the card).

## Preconditions

* Github project with _Project_ board that has multiple columns
* Labels that match the names of the columns
* A web server to deploy the script to (e.g. Heroku)

## Deployment

When the script is deployed on a web server, it will expose an endpoint at the location `http(s)://somehost.com/card_moved`. You also need to set two environment variables for the script, `ACCESS_TOKEN` which must contain a Github access token that has enough rights to read and modify issues on your repository and `PROJECT_NAMES` which must contains the list of Github Project names (as a list with `;` separator character) that the script should track for card moves (e.g. `My first board` or (for more then one project) `Sample Project;Another project`)

If you don't have a web server to deploy the script on, use a free instance of Heroku (https://www.heroku.com/). If you want to run it on your own server (or service), just deploy it as a rack app. I recommend the script to run via HTTPS.

__Important__:
* Please __be aware that the script does not validate the origin of the caller__. Github allows to add a signature to the webbook request, but i have not included any validation.

Once the endpoint is publicly accessible, add a new __Webhook__ to your Github repository. The Webhook _Payload URL_ must point to the URL of the endpoint (`https://somehost.com/card_moved`), the _Content type_ must be set to `application/json` and as the _trigger_ select the _event_ `Project card`.

No everything is ready to be used. When you move an issue card in your Github Project from one column to another, the labels that match the column names will be added and removed.

## Feedback

If you find any issues in the script, feel free to open an issue or send me a pull request.

If you want to get in touch with me, please contact me via Twitter at  [@doerfli](https://twitter.com/doerfli).
