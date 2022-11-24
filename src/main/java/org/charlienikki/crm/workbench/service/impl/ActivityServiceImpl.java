package org.charlienikki.crm.workbench.service.impl;

import org.charlienikki.crm.workbench.domain.Activity;
import org.charlienikki.crm.workbench.mapper.ActivityMapper;
import org.charlienikki.crm.workbench.service.ActivityService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService {

    @Resource
    private ActivityMapper activityMapper;

    @Override
    public int saveCreateActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    @Override
    public int deleteActivitiesByIds(String[] ids) {
        return activityMapper.deleteActivitiesByIds(ids);
    }

    @Override
    public int updateActivityById(Activity activity) {
        return activityMapper.updateActivityById(activity);
    }

    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    @Override
    public List<Activity> queryAllActivitiesForDownload() {
        return activityMapper.selectAllActivitiesForDownload();
    }

    @Override
    public List<Activity> queryActivitiesByIds(String[] ids) {
        return activityMapper.selectActivitiesByIds(ids);
    }

    @Override
    public List<Activity> queryActivitiesByConditionForPage(Map<String,Object> map) {
        return activityMapper.selectActivitiesByConditionForPage(map);
    }

    @Override
    public int queryCountOfActivitiesByCondition(Map<String, Object> map) {
        return activityMapper.selectCountOfActivitiesByCondition(map);
    }
}
