package org.charlienikki.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class IndexController {

    @RequestMapping("/")
    public String index() {
        // 请求转发登陆页面,视图解析器自动拼接视图
        return "index";
    }
}
