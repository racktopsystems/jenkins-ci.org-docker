FROM ubuntu:14.04
MAINTAINER <Sam Zaydel szaydel@racktopsystems.com>

RUN echo "1.565.1" > .lts-version-number

RUN apt-get update && apt-get install -y wget git curl zip
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-7-jdk
RUN apt-get update && apt-get install -y maven ant ruby rbenv make

RUN wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | sudo apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian-stable binary/ >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y jenkins
RUN mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home

# Setup ssh config
RUN mkdir -p /var/lib/jenkins/.ssh
RUN printf "Host *\n    User jenkins\n    IdentityFile /var/jenkins_home/.ssh/id_rsa\n" > /var/lib/jenkins/.ssh/config
RUN chmod 700 /var/lib/jenkins/.ssh && chown -R jenkins /var/lib/jenkins/.ssh

ADD init.groovy /tmp/WEB-INF/init.groovy
RUN cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy
ADD ./jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod +x /usr/local/bin/jenkins.sh
USER jenkins

# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV JENKINS_HOME /var/jenkins_home

# define url prefix for running jenkins behind Apache (https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)
ENV JENKINS_PREFIX /

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

CMD ["/usr/local/bin/jenkins.sh"]
