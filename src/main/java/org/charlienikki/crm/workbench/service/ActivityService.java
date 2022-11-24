package org.charlienikki.crm.workbench.service;

import org.charlienikki.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    int saveCreateActivity(Activity activity);

    /**
     * 查询符合条件的所有市场活动
     * @param map
     * @return
     */
    List<Activity> queryActivitiesByConditionForPage(Map<String,Object> map);

    /**
     * 查询符合条件的所有市场活动的总条数
     * @param map
     * @return
     */
    int queryCountOfActivitiesByCondition(Map<String,Object> map);

    int deleteActivitiesByIds(String[] ids);

    int updateActivityById(Activity activity);

    Activity queryActivityById(String id);

    List<Activity> queryAllActivitiesForDownload();

    List<Activity> queryActivitiesByIds(String[] ids);
}
