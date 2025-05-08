def call(apps, action) {
    buildStageList = []
    buildParallelMap = [:]
    apps.each { app, value ->
        if (action == "build, test") {
            buildParallelMap.put(app, stageBuildCreateMP(app, value))
        }
        if (action == "build, upload") {
            buildParallelMap.put(app, stageUploadCreateMP(app, value))
        }
    }
    buildStageList.add(buildParallelMap)
    return buildStageList
}