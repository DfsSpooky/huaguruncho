import uuid
from django.db import models


class TimeStampedModel(models.Model):
    """
    Abstract model that provides self-updating created_at and updated_at fields.
    """
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Fecha de creación', db_index=True)
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Última actualización')

    class Meta:
        abstract = True


class UUIDModel(models.Model):
    """
    Abstract model that provides a public UUID v4 field.
    """
    uuid = models.UUIDField(
        default=uuid.uuid4,
        editable=False,
        unique=True,
        db_index=True,
        verbose_name='Identificador único público (UUID)'
    )

    class Meta:
        abstract = True
