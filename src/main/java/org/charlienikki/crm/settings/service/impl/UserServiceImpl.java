package org.charlienikki.crm.settings.service.impl;

import org.charlienikki.crm.settings.mapper.UserMapper;
import org.charlienikki.crm.settings.pojo.User;
import org.charlienikki.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {

    @Resource
    private UserMapper userMapper;

    @Override
    public List<User> queryAllUsers() {
        return userMapper.selectAllUsers();
    }

    /**
     * 获取到前方传来的map集合(用户输入的数据)之后，调用数据库进行查询
     * 进行比对，能否
     * @param map
     * @return
     */
    @Override
    public User queryUserByLoginActAndPwd(Map<String, Object> map) {
        // 调用mapper层的方法，从数据库中查询数据
        return userMapper.selectUserByLoginActAndPwd(map);
    }
}
