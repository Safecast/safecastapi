FROM circleci/ruby:2.6.8-node-browsers

RUN sudo apt-get update && sudo apt-get install postgresql-client python -y
RUN curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py | sudo python
RUN sudo pip install awscli awsebcli==3.19.4
