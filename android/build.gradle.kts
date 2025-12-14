buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // هذا السطر ضروري لكي يعمل الأندرويد
        classpath("com.android.tools.build:gradle:8.1.0") // قد يختلف الرقم قليلاً حسب مشروعك، لكن هذا يعمل غالباً
        
        // --- هذا هو السطر المهم الذي أضفناه لـ Firebase ---
        classpath("com.google.gms:google-services:4.4.1")
        // --------------------------------------------------
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}