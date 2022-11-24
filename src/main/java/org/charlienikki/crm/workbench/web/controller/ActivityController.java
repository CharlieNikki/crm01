package org.charlienikki.crm.workbench.web.controller;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.charlienikki.crm.commons.constants.Constant;
import org.charlienikki.crm.commons.domain.UserMessage;
import org.charlienikki.crm.commons.utils.DateUtils;
import org.charlienikki.crm.commons.utils.HSSUtils;
import org.charlienikki.crm.commons.utils.UUIDUtil;
import org.charlienikki.crm.settings.pojo.User;
import org.charlienikki.crm.settings.service.UserService;
import org.charlienikki.crm.workbench.domain.Activity;
import org.charlienikki.crm.workbench.service.ActivityService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.*;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
public class ActivityController {
    @Resource
    private UserService userService;

    @Resource
    private ActivityService activityService;

    /**
     * “市场活动”链接对应的controller
     * @param request
     * @return
     */
    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request) {

        List<User> users = userService.queryAllUsers();
        request.setAttribute("users", users);
        // data forward:
        return "workbench/activity/index";
    }

    @RequestMapping("/workbench/activity/saveActivity.do")
    public @ResponseBody Object saveActivity(Activity activity, HttpSession session) {

        // 封装参数
        activity.setId(UUIDUtil.getUUID());
        activity.setCreateTime(DateUtils.formatDateTime(new Date()));
        // 强转
        User user = (User) session.getAttribute(Constant.SESSION_USER);
        activity.setCreateBy(user.getId());

        UserMessage u = new UserMessage();

        try {
            int i = activityService.saveCreateActivity(activity);
            if (i > 0) {
                // success,flush
                u.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                // fail，show message on browser
                u.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                u.setMessage("fail to insert");
            }
        } catch (Exception e) {
            e.printStackTrace();
            u.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            u.setMessage("fail to insert");
        }
        return u;
    }

    @RequestMapping("/workbench/activity/queryActivitiesByConditionForPage.do")
    public @ResponseBody Object queryActivitiesByConditionForPage(String name, String owner, String startDate,
                                                                  String endDate, Integer pageSize, Integer pageNo) {
        // 封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("pageSize", pageSize);
        map.put("beginNo", (pageNo-1)*pageSize);

        // 查询数据
        List<Activity> activities = activityService.queryActivitiesByConditionForPage(map);
        int countsOfActivities = activityService.queryCountOfActivitiesByCondition(map);
        // 生成响应信息,由@ResponseBody自动转换为json字符串传给前端
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("activities", activities);
        retMap.put("countsOfActivities", countsOfActivities);
        return retMap;
    }

    @RequestMapping("/workbench/activity/deleteActivities.do")
    public @ResponseBody Object deleteActivities(String[] id) {
        UserMessage u = new UserMessage();
        try {
            int ret = activityService.deleteActivitiesByIds(id);
            if (ret > 0) {
                u.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                u.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                u.setMessage("fail to delete");
            }
        } catch (Exception e) {
            e.printStackTrace();
            u.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            u.setMessage("fail to delete");
        }
        return u;
    }

    @RequestMapping("/workbench/activity/updateActivity.do")
    public @ResponseBody Object updateActivity(Activity activity, HttpSession session) {

        // 添加修改者
        User user = (User) session.getAttribute(Constant.SESSION_USER);
        activity.setEditBy(user.getId());
        // 添加修改时间
        activity.setEditTime(DateUtils.formatDateTime(new Date()));

        UserMessage u = new UserMessage();
        try {
            int ret = activityService.updateActivityById(activity);
            if (ret > 0) {
                u.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                u.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                u.setMessage("fail to update");
            }
        } catch (Exception e) {
            e.printStackTrace();
            u.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            u.setMessage("fail to update");
        }
        return u;
    }

    @RequestMapping("/workbench/activity/selectAnActivity.do")
    public @ResponseBody Object selectAnActivity(String id) {
        return activityService.queryActivityById(id);
    }


    @RequestMapping("/workbench/activity/activitiesDownload.do")
    public void activitiesDownload(HttpServletResponse response) throws Exception {

        // 调用service层的方法，查询所有的市场活动
        List<Activity> activities = activityService.queryAllActivitiesForDownload();
        // 创建excel文件，并把activities写入文件中
        HSSFWorkbook workbook = HSSUtils.activity2Excel(activities);
        // 把生成的excel对象下载到浏览器客户端
        response.setContentType("application/octet-stream;charset=utf-8");
        response.addHeader("Content-Disposition", "attachment;filename=activities.xls");
        OutputStream outputStream = response.getOutputStream();

        workbook.write(outputStream);
        workbook.close();
        outputStream.flush();
    }

    @RequestMapping("/workbench/activity/partOfActivitiesDownload.do")
    public void partOfActivitiesDownload(String[] id, HttpServletResponse response) throws Exception {
        List<Activity> activities = activityService.queryActivitiesByIds(id);
        HSSFWorkbook workbook = HSSUtils.activity2Excel(activities);
        // 把生成的excel对象下载到浏览器客户端
        response.setContentType("application/octet-stream;charset=utf-8");
        response.addHeader("Content-Disposition", "attachment;filename=activities.xls");
        OutputStream outputStream = response.getOutputStream();

        workbook.write(outputStream);
        workbook.close();
        outputStream.flush();
    }
}
