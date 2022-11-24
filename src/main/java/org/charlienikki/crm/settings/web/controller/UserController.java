package org.charlienikki.crm.settings.web.controller;

import org.charlienikki.crm.commons.constants.Constant;
import org.charlienikki.crm.commons.domain.UserMessage;
import org.charlienikki.crm.commons.utils.DateUtils;
import org.charlienikki.crm.settings.pojo.User;
import org.charlienikki.crm.settings.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/settings/qx/user")
public class UserController {

    @Resource
    private UserService userService;

    /**
     * 进入登录页面controller
     * @return 登陆页面视图路径
     */
    @RequestMapping("/toLogin.do")
    public String toLogin() {
        return "settings/qx/user/login";
    }

    /**
     * user login controller
     * @param loginAct
     * @param loginPwd
     * @param isRemPwd
     * @param request
     * @param session
     * @param response
     * @return
     */
    @RequestMapping("/login.do")
    public @ResponseBody Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request,
                                      HttpSession session, HttpServletResponse response) {
        Map<String,Object> map = new HashMap<>();
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);

        // get user
        User user = userService.queryUserByLoginActAndPwd(map);

        // return message
        UserMessage userMessage = new UserMessage();

        if (null == user) {
            // username or password is incorrect
            userMessage.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            userMessage.setMessage("Your username or password is incorrect");
        } else {
            if (DateUtils.formatDateTime(new Date()).compareTo(user.getExpireTime()) > 0) {
                // expired
                userMessage.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                userMessage.setMessage("Your account has expired");
            } else if ("0".equals(user.getLockState())) {
                // locked
                userMessage.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                userMessage.setMessage("Your account has been locked");
            } else if (!user.getAllowIps().contains(request.getRemoteAddr())) {
                // restricted
                userMessage.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                userMessage.setMessage("Your IP address is restricted");
            } else {
                // successful
                userMessage.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
                // set session
                session.setAttribute(Constant.SESSION_USER, user);
                // 'isRemPwd' checkbox checked
                Cookie c1;
                Cookie c2;
                if ("true".equals(isRemPwd)) {
                    // new cookie
                    c1 = new Cookie("loginAct", loginAct);
                    c2 = new Cookie("loginPwd", loginPwd);
                    // set cookie's max age
                    c1.setMaxAge(10 * 24 * 60 * 60);
                    c2.setMaxAge(10 * 24 * 60 * 60);
                    // add cookie to browse
                } else {
                    // delete cookie
                    c1 = new Cookie("loginAct", "1");
                    c2 = new Cookie("loginPwd", "1");
                    c1.setMaxAge(0);
                    c2.setMaxAge(0);
                }
                // cover
                response.addCookie(c1);
                response.addCookie(c2);
            }
        }
        return userMessage;
    }

    /**
     * user exits the system 'safely'
     * @param response
     * @param session
     * @return
     */
    @RequestMapping("/safeExit.do")
    public String safeExit(HttpServletResponse response, HttpSession session) {
        // invalidate session
        session.invalidate();
        // delete cookie anyway
        Cookie cAct = new Cookie("loginAct", "1");
        Cookie cPwd = new Cookie("loginPwd", "1");
        cAct.setMaxAge(0);
        cPwd.setMaxAge(0);
        response.addCookie(cAct);
        response.addCookie(cPwd);

        return "redirect:/";
    }
}
