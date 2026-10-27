from rest_framework import status, generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView
from drf_spectacular.utils import extend_schema
from .serializers import (
    UserSerializer,
    RegisterSerializer,
    LoginSerializer,
    AuthResponseSerializer
)
from .models import User


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = (permissions.AllowAny,)

    @extend_schema(
        summary="Registro de nuevo turista",
        description="Crea una nueva cuenta de usuario turista y retorna tokens JWT.",
        responses={201: AuthResponseSerializer}
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        tokens = get_tokens_for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'tokens': tokens
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = LoginSerializer

    @extend_schema(
        summary="Inicio de sesión",
        description="Autentica al usuario con correo y contraseña, retornando tokens JWT.",
        request=LoginSerializer,
        responses={200: AuthResponseSerializer}
    )
    def post(self, request):
        serializer = LoginSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        tokens = get_tokens_for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'tokens': tokens
        }, status=status.HTTP_200_OK)


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAuthenticated,)

    @extend_schema(
        summary="Perfil del usuario autenticado",
        description="Obtiene o actualiza la información del usuario en sesión."
    )
    def get_object(self):
        return self.request.user
