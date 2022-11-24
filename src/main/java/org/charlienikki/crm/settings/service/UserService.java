package org.charlienikki.crm.settings.service;

import org.charlienikki.crm.settings.pojo.User;

import java.util.List;
import java.util.Map;

public interface UserService {

    User queryUserByLoginActAndPwd(Map<String,Object> map);

    List<User> queryAllUsers();
}
