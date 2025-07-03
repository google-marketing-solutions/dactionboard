# dActionBoard - Video Action Campaigns Reporting

## Table of Content
1. [Introduction](#introduction)
1. [Deliverables](#deliverables)
1. [Prerequisites](#prerequisites)
1. [Installation](#installation)
    * [Manual installation in Google Cloud](#manual-installation-in-google-cloud)
    * [Gaarf Workflow Installation in Google Cloud](#gaarf-workflow-installation-in-google-cloud)
    * [Alternative Installation Methods](#alternative-installation-methods)
        * [Prerequisites for alternative installation methods](#prerequisites-for-alternative-installation-methods)
        * [Running Queries Locally](#running-queries-locally)
        * [Running in a Docker Container](#running-in-a-docker-container)
        * [Running in Apache Airflow](#running-in-apache-airflow)
1. [Dashboard Replication](#dashboard-replication)
1. [Disclaimer](#disclaimer)


## Introduction

Crucial information on Video Action campaigns - especially related to video-level
performance and creative excellence - is scattered across various places in
Google Ads UI which make it harder to get insights into how campaigns and
video perform.

dActionBoard is Data Studio based dashboard that provides a comprehensive overview of your Video Action campaigns.

Key pillars of dActionBoard:

* High level overview of Video Action campaigns performance
* Deep dive analysis (by age, gender, geo, devices, etc.)
* Overview of creative excellence and ways of improving campaign performance based on Google recommendations
* Video level analytics

## Deliverables

1. A centralized dashboard with deep video campaign and assets performance views
2. The following data tables in BigQuery that can be used independently:

List of tables:
* `ad_video_performance`
* `age_performance`
* `conversion_split`
* `creative_excellence`
* `device_performance`
* `gender_performance`
* `geo_performance`
* `video_conversion_split`
* `video_performance`

## Prerequisites
*Back to [table of content](#table-of-content)*

1. Standard access to Google Ads account(s):
    - person responsible for deploying APG should have *Standard* access to an MCC account.
1. Credentials for Google Ads API access which stored in `google-ads.yaml`.
   See details [here](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md).
1. A Google Cloud project with billing account attached.

1. Membership in [dactionboard-readers-external](https://groups.google.com/g/dactionboard) group to get access to the template dashboard and datasources. You can apply [here](https://groups.google.com/g/dactionboard).


## Installation
There are several ways to run the application. A recommended way is to run it
in the Google Cloud but it's not a requirement. You can run dActionBoard locally or
in your own infrastructure. In either way you need two things:
* Google Ads API credentials (in `google-ads.yaml` or separately)
* dActionBoard configuration (in `dactionboard.yaml`) - it can be generated via running `run-local.sh`.
In order to run dActionBoard please follow the steps outlined below:

### Manual installation in Google Cloud
*Back to [table of content](#table-of-content)*

1. First you need to clone the repo in Cloud Shell or on your local machine (we assume Linux with gcloud CLI installed):
```
git clone https://github.com/google-marketing-solutions/dactionboad
```

1. Go to the repo folder: `cd dactionboard`

1. Optionally put your `google-ads.yaml` there or be ready to provide all Ads API credentials

1. Optionally adjust settings in `settings.ini`

1. Run installation:
```
./gcp/install.sh
```

If you already have dActionBoard configuration (`dactionboard.yaml`) then you can directly deploy all components via running:
```
./gcp/setup.sh deploy_public_index deploy_all start
```

>TIP: when you install via clicking Cloud Run Button basically you run the same install.sh but in an automatically created Shell.


The setup script with 'deploy_all' target does the followings:
* enable APIs
* grant required IAM permissions
* create a repository in Artifact Repository
* build a Docker image (using `gcp/workload-vm/Dockerfile` file)
* publish the image into the repository
* deploy Cloud Function `create-vm` (from gcp/cloud-functions/create-vm/) (using environment variables in env.yaml file)
* deploy configs to GCS (config.yaml and google-ads.yaml) (to a bucket with a name of current GCP project id and 'dactionboard' subfolder)
* create a Scheduler job for publishing a pubsub message with arguments for the CF

The setup script with 'deploy_public_index' uploads the index.html webpage on a GCS public bucket,
the page that you can use to track installation progress, and create a dashboard at the end.

What happens when a pubsub message published (as a result of `setup.sh start`):
* the Cloud Function 'create-vm' get a message with arguments and create a virtual machine based a Docker container from the Docker image built during the installation
* the VM on startup parses the arguments from the CF (via VM's attributes) and execute dActionBoard in quite the same way as it executes locally (using `run-local.sh`).
Additionally the VM's entrypoint script deletes the virtual machine upon completion of the run-local.sh.


### Gaarf Workflow Installation in Google Cloud
*Back to [table of content](#table-of-content)*

You can use [Gaarf Workflows](https://github.com/google/ads-api-report-fetcher/tree/main/gcp) to deploy dactionBoard.

1. Clone this repository and go to dactionboard folder `cd dactionboard`
2. Start the interactive generation `npm init gaarf-wf@latest -- --answers=answers.json`
> You need Node.js and npm installed to complete the previous step.
3. Follow steps outlined in the interactive tool.
4. Once the installation is completed you'll get a link for replicating the dashboard.

### Alternative Installation Methods
*Back to [table of content](#table-of-content)*

#### Prerequisites for alternative installation methods

* Google Ads API access and [google-ads.yaml](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md#setting-up-using-google-adsyaml) file - follow documentation on [API authentication](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md).
* Python 3.8+
* [Service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating) created and [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating) downloaded in order to write data to BigQuery.
    * Once you downloaded service account key export it as an environmental variable
        ```
        export GOOGLE_APPLICATION_CREDENTIALS=path/to/service_account.json
        ```

    * If authenticating via service account is not possible you can authenticate with the following command:
         ```
         gcloud auth application-default login
         ```

#### Running queries locally
*Back to [table of content](#table-of-content)*

In order to run dActionBoard locally please follow the steps outlined below:

* clone this repository
    ```
    git clone https://github.com/google/dactionboard
    cd dactionboard
    ```
* (Recommended) configure virtual environment if you starting testing the solution:
    ```
    sudo apt-get install python3-venv
    python3 -m venv dactionboard
    source dactionboard/bin/activate
    ```
* Make sure that that pip is updated to the latest version:
    ```
    python3 -m pip install --upgrade pip
    ```
* install dependencies:
    ```
    pip install --require-hashes -r app/requirements.txt --no-deps
    ```
Please run `app/run-local.sh` script in a terminal to generate all necessary tables for dActionBoard:

```shell
bash ./app/run-local.sh
```

It will guide you through a series of questions to get all necessary parameters to run the scripts:

* `account_id` - id of Google Ads MCC account (no dashes, 111111111 format)
* `BigQuery project_id` - id of BigQuery project where script will store the data (i.e. `my_project`)
* `BigQuery dataset` - id of BigQuery dataset where script will store the data (i.e. `my_dataset`)
* `start date` - first date from which you want to get performance data (i.e., `2022-01-01`). Relative dates are supported [see more](https://github.com/google/ads-api-report-fetcher#dynamic-dates).
* `end date` - last date from which you want to get performance data (i.e., `2022-12-31`). Relative dates are supported [see more](https://github.com/google/ads-api-report-fetcher#dynamic-dates).
* `Ads config` - path to `google-ads.yaml` file.

After the initial run of `run-local.sh` command it will generate `dactionboard.yaml` config file with all necessary information used for future runs.
When you run `bash app/run-local.sh` next time it will automatically pick up created configuration.

##### Schedule running `run-local.sh` as a cronjob

When running `app/run-local.sh` scripts you can specify two options which are useful when running queries periodically (i.e. as a cron job):

* `-c <config>`- path to `dactionboard.yaml` config file. Comes handy when you have multiple config files or the configuration is located outside of current folder.
* `-q` - skips all confirmation prompts and starts running scripts based on config file.

If you installed all requirements in a virtual environment you can use the trick below to run the proper cronjob:

```
* 1 * * * /usr/bin/env bash -c "source /path/to/your/venv/bin/activate && bash /path/to/dactionboard/app/run-local.sh -c /path/to/dactionboard.yaml -g /path/to/google-ads.yaml -q"
```

This command will execute dActionBoard queries every day at 1 AM.

#### Running in a Docker Container
*Back to [table of content](#table-of-content)*

You can run dActionBoard queries inside a Docker container.

```
sudo docker run \
   -v /path/to/google-ads.yaml:/google-ads.yaml \
   -v /path/to/dactionboard.yaml:/config.yaml \
   -v /path/to/service_account.json:/service_account.json \
   ghcr.io/google-marketing-solutions/dactionboard

```
where:
* `/path/to/google-ads.yaml` - absolute path to `google-ads.yaml` file (can be remote)
* `service_account.json` - absolute path to service account json file
* `/path/to/dactionboard.yaml` - absolute path to YAML config

> Don't forget to change /path/to/google-ads.yaml and /path/to/service_account.json with valid paths.

You can provide configs as remote (for example Google Cloud Storage):

```
sudo docker run  \
  -e GOOGLE_CLOUD_PROJECT="project_name" \
  -v /path/to/service_account.json:/service_account.json \
  ghcr.io/google-marketing-solutions/dactionboard \
  gs://project_name/google-ads.yaml \
  gs://project_name/dactionboard.yaml
```
#### Running in Apache Airflow
*Back to [table of content](#table-of-content)*

Please refer to [documentation](docs/running-dactionboard-in-apache-airflow.md)
on running dActionBoard in Apache Airflow.

#### Dashboard Replication
*Back to [table of content](#table-of-content)*

In order to generate the dashboard install [Looker Studio Dashboard Cloner](https://github.com/google/looker-studio-dashboard-cloner)
and run the following command in the terminal:

```
lsd-cloner --answers=dashboard_answers.json
```

This command will open a link in your browser with a copy of the dashboard.
Alternatively you can follow the documentation on dashboard replication at [how-to-replicate-dashboard](docs/how-to-replicate-dashboard.md) section in docs.

> **_IMPORTANT:_** After the dashboard is created you need to enable image previews, read details on how it can be done [here](docs/how-to-replicate-dashboard.md#enable-image-previews).


## Disclaimer
This is not an officially supported Google product.
