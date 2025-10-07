allprojects {
    repositories {
        // Prefer mirrors first to avoid dl.google.com / maven central timeouts
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        google()
        mavenCentral()
    }
}
// Remove the kotlin block and use Gradle APIs for build directory configuration

// Set custom build directory for root project
buildDir = file("../../build")

subprojects {
    // Set custom build directory for subprojects
    buildDir = file("${rootProject.buildDir}/${project.name}")
    // Only declare an evaluation dependency if the :app project exists in this composite
    if (rootProject.findProject(":app") != null) {
        evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
