FROM registry.access.redhat.com/ubi9/openjdk-21-runtime:1.20
# When initially conceived, this was a good and healthy JDK runtime image.
# However, as a good practice for production applications, consider
# moving to Red Hat Hardened Images as a foundational layer.
# Check https://images.redhat.com/ for trusted, distroless, and micro-sized components

# FROM registry.access.redhat.com/hi/openjdk:21-runtime

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

COPY --chown=185 target/quarkus-app/lib/ /deployments/lib/
COPY --chown=185 target/quarkus-app/*.jar /deployments/
COPY --chown=185 target/quarkus-app/app/ /deployments/app/
COPY --chown=185 target/quarkus-app/quarkus/ /deployments/quarkus/

EXPOSE 8080
USER 185

#ubi-jdk images use a script as an entrypoint, Hardened Images are distroless, so don't have a shell.
#the explicit entrypoint includes the java tuning settings from the ubi-jdk image
#but works across classic and hardened images

ENTRYPOINT [ "java", \
  "-XX:MaxRAMPercentage=80.0", \
  "-XX:+UseParallelGC", \
  "-XX:MinHeapFreeRatio=10", \
  "-XX:MaxHeapFreeRatio=20", \
  "-XX:GCTimeRatio=4", \
  "-XX:AdaptiveSizePolicyWeight=90", \
  "-XX:+ExitOnOutOfMemoryError", \
  "-Dquarkus.http.host=0.0.0.0", \
  "-Djava.util.logging.manager=org.jboss.logmanager.LogManager", \
  "-jar", "/deployments/quarkus-run.jar" ]
