def call(apps, action) {
    buildStageList = []
    buildParallelMap = [:]
    apps.each { app, value ->
        if (action == "deploy") {
            buildParallelMap.put(app, stageDeploy(app, value))
        }
        if (action == "run") {
            buildParallelMap.put(app, stageRun(app, value))
        }
    }
    buildStageList.add(buildParallelMap)
    return buildStageList
}