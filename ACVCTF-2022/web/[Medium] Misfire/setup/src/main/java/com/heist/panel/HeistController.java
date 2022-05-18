package com.heist.panel;

import org.springframework.ui.Model;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HeistController {

    @GetMapping(value="/posts")
    public String posts() {
        return "";
    }

    @RequestMapping(value = "/posts/delete")
    @ResponseBody
    public String deletePostsBySimplePath() {
        return "Panel Posts Delete: Removed";
    }

    @GetMapping(value="/users")
    public String users() {
        return "";
    }

    @PostMapping("/panel/status")
    public String panelStatus(@ModelAttribute PanelItems status, Model model) {
        return "Panel Status: OK";
    }

    @PostMapping("/panel/update")
    public String panelSubmit(@ModelAttribute PanelItems update, Model model) {
        return "Panel Update: Model yet to build";
    }

    @GetMapping(value="/comments")
    public String comments() {
        return "";
    }

    @GetMapping(value="/issues")
    public String issues() {
        return "";
    }

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        String[] clist = {"class.*","*.class.*"};
        binder.setDisallowedFields(clist);
    }

    @GetMapping(value="/patches")
    public String patches() {
        return "";
    }

}