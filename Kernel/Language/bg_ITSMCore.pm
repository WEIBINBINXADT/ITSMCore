# --
# Kernel/Language/bg_ITSMCore.pm - the bulgarian translation of ITSMCore
# Copyright (C) 2001-2007 OTRS GmbH, http://otrs.org/
# --
# $Id: bg_ITSMCore.pm,v 1.1.2.1 2007-12-03 15:51:23 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::Language::bg_ITSMCore;

use strict;
use warnings;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Priority Management'} = '���������� �� ������������';
    $Self->{Translation}->{'Add a new Priority.'} = '������ ��� ���������.';
    $Self->{Translation}->{'Add Priority'} = '������ ���������';

    $Self->{Translation}->{'Criticality'} = '����������';
    $Self->{Translation}->{'Impact'} = '�������';
    $Self->{Translation}->{'Criticality <-> Impact <-> Priority'} = '����������<->�������<->���������';
    $Self->{Translation}->{'allocate'} = '���������';

    $Self->{Translation}->{'Relevant to'} = '��������� �';
    $Self->{Translation}->{'Includes'} = '��������';
    $Self->{Translation}->{'Part of'} = '���� ��';
    $Self->{Translation}->{'Depends on'} = '������ ��';
    $Self->{Translation}->{'Required for'} = '��������� ��';
    $Self->{Translation}->{'Connected to'} = '������� �';
    $Self->{Translation}->{'Alternative to'} = '������������ ��';

    return 1;
}

1;