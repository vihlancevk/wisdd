package sber.course.controller;

import org.springframework.web.bind.annotation.*;
import sber.course.entity.User;
import sber.course.repository.UserRepository;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class HelloController {
    private final UserRepository repository;

    public HelloController(UserRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<User> getAll() {
        return repository.findAll();
    }

    @PostMapping
    public User create(@RequestBody User user) {
        return repository.save(user);
    }
}
