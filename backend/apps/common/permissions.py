from rest_framework import permissions


class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Permite lectura a cualquier usuario (incluso anónimo), pero escritura solo a administradores.
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return bool(request.user and request.user.is_authenticated and (request.user.is_staff or getattr(request.user, 'role', '') == 'administrador'))


class IsMunicipalidadOrAdmin(permissions.BasePermission):
    """
    Permite acceso solo a usuarios administradores, personal municipal o guardaparques.
    """
    def has_permission(self, request, view):
        return bool(
            request.user and request.user.is_authenticated and (
                request.user.is_staff or 
                getattr(request.user, 'role', '') in ['administrador', 'municipalidad', 'guardaparque']
            )
        )


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Permite modificar u observar un objeto solo al creador del mismo o a un administrador/guardaparque.
    """
    def has_object_permission(self, request, view, obj):
        if not request.user or not request.user.is_authenticated:
            return False
        if request.user.is_staff or getattr(request.user, 'role', '') in ['administrador', 'municipalidad', 'guardaparque']:
            return True
        return getattr(obj, 'user', None) == request.user
