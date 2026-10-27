from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('El correo electrónico es obligatorio.')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', User.Role.ADMINISTRADOR)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('El superusuario debe tener is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('El superusuario debe tener is_superuser=True.')

        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    class Role(models.TextChoices):
        TURISTA = 'turista', 'Turista'
        GUIA = 'guia', 'Guía Autorizado'
        ADMINISTRADOR = 'administrador', 'Administrador'
        MUNICIPALIDAD = 'municipalidad', 'Personal Municipal / Guardaparque'
        GUARDAPARQUE = 'guardaparque', 'Guardaparque / Guardabosques'

    email = models.EmailField(
        unique=True,
        max_length=255,
        verbose_name='Correo Electrónico',
        db_index=True
    )
    full_name = models.CharField(
        max_length=255,
        verbose_name='Nombre Completo'
    )
    phone = models.CharField(
        max_length=30,
        blank=True,
        null=True,
        verbose_name='Teléfono / WhatsApp'
    )
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.TURISTA,
        verbose_name='Rol del Usuario'
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo'
    )
    is_staff = models.BooleanField(
        default=False,
        verbose_name='Acceso al Panel Admin'
    )
    date_joined = models.DateTimeField(
        default=timezone.now,
        verbose_name='Fecha de Registro'
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        verbose_name='Última Actualización'
    )

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']

    class Meta:
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
        ordering = ['-date_joined']

    def __str__(self):
        return f"{self.full_name} ({self.email}) - {self.get_role_display()}"
