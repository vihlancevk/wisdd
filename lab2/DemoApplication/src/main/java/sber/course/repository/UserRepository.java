package sber.course.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sber.course.entity.User;

public interface UserRepository extends JpaRepository<User, Long> {
}
