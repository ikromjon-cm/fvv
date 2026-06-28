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

// Force any plugin compiled against an older Android SDK (e.g. smart_auth on
// android-31) up to compileSdk 36, which newer AndroidX deps require (>=33).
// :app is skipped — it already uses Flutter's compileSdk (36) and is
// force-evaluated by the evaluationDependsOn block above, so registering a new
// afterEvaluate on it would fail.
subprojects {
    if (name != "app") {
        afterEvaluate {
            val androidExt = extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
            if (androidExt != null) {
                val currentSdk = androidExt.compileSdkVersion
                    ?.substringAfter("-")
                    ?.toIntOrNull() ?: 0
                if (currentSdk < 36) {
                    androidExt.compileSdkVersion(36)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
