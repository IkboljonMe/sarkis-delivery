allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force every Android plugin subproject to compile against a modern SDK.
fun forceCompileSdk(project: org.gradle.api.Project) {
    val androidExt = project.extensions.findByName("android") ?: return
    val setCompileSdk = androidExt.javaClass.methods.firstOrNull {
        it.name == "compileSdkVersion" &&
            it.parameterTypes.size == 1 &&
            it.parameterTypes[0] == Int::class.javaPrimitiveType
    }
    setCompileSdk?.invoke(androidExt, 36)
}

subprojects {
    if (state.executed) {
        forceCompileSdk(project)
    } else {
        afterEvaluate { forceCompileSdk(project) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
