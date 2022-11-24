package org.charlienikki.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WorkbenchController {

    @RequestMapping("/workbench/toIndex.do")
    public String toIndex() {
        return "/workbench/index";
    }
}
