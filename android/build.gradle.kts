import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Her proje evaluate edildikten sonra compileSdk'yi ayarla
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                androidExt::class.java
                    .getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(androidExt, 36)
            } catch (_: Exception) {
                // Yoksay
            }
        }
    }
}

rootProject.layout.buildDirectory.set(File("../build"))

subprojects {
    project.layout.buildDirectory.set(File("${rootProject.layout.buildDirectory.get()}/${project.name}"))
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}