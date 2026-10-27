from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'full_name', 'phone', 'role', 'date_joined')
        read_only_fields = ('id', 'role', 'date_joined')


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ('id', 'email', 'password', 'full_name', 'phone')

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            full_name=validated_data['full_name'],
            phone=validated_data.get('phone', ''),
            role=User.Role.TURISTA
        )
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        if email and password:
            user = authenticate(request=self.context.get('request'), email=email, password=password)
            if not user:
                raise serializers.ValidationError('Credenciales inválidas. Verifica tu correo y contraseña.')
            if not user.is_active:
                raise serializers.ValidationError('Esta cuenta ha sido desactivada.')
        else:
            raise serializers.ValidationError('Debe incluir "email" y "password".')

        attrs['user'] = user
        return attrs


class AuthResponseSerializer(serializers.Serializer):
    user = UserSerializer()
    tokens = serializers.DictField()
