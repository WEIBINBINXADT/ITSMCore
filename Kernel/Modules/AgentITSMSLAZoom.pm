# --
# Kernel/Modules/AgentITSMSLAZoom.pm - the OTRS::ITSM SLA zoom module
# Copyright (C) 2001-2008 OTRS AG, http://otrs.org/
# --
# $Id: AgentITSMSLAZoom.pm,v 1.5 2008-08-02 15:01:11 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --

package Kernel::Modules::AgentITSMSLAZoom;

use strict;
use warnings;

use Kernel::System::Service;
use Kernel::System::SLA;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.5 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(ConfigObject ParamObject DBObject LayoutObject LogObject)) {
        if ( !$Self->{$Object} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Object!" );
        }
    }
    $Self->{ServiceObject} = Kernel::System::Service->new(%Param);
    $Self->{SLAObject}     = Kernel::System::SLA->new(%Param);

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get params
    my $SLAID = $Self->{ParamObject}->GetParam( Param => "SLAID" );

    # check needed stuff
    if ( !$SLAID ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => "No SLAID is given!",
            Comment => 'Please contact the admin.',
        );
    }

    # get sla
    my %SLA = $Self->{SLAObject}->SLAGet(
        SLAID  => $SLAID,
        UserID => $Self->{UserID},
    );
    if ( !$SLA{SLAID} ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => "SLAID $SLAID not found in database!",
            Comment => 'Please contact the admin.',
        );
    }

    # get calendar name
    if ( $SLA{Calendar} ) {
        $SLA{CalendarName} = "Calendar $SLA{Calendar} - "
            . $Self->{ConfigObject}->Get( "TimeZone::Calendar" . $SLA{Calendar} . "Name" );
    }
    else {
        $SLA{CalendarName} = 'Calendar Default';
    }

    # run config item menu modules
    if ( ref $Self->{ConfigObject}->Get('ITSMSLA::Frontend::MenuModule') eq 'HASH' ) {
        my %Menus   = %{ $Self->{ConfigObject}->Get('ITSMSLA::Frontend::MenuModule') };
        my $Counter = 0;
        for my $Menu ( sort keys %Menus ) {

            # load module
            if ( $Self->{MainObject}->Require( $Menus{$Menu}->{Module} ) ) {
                my $Object = $Menus{$Menu}->{Module}->new(
                    %{$Self},
                    SLAID => $Self->{SLAID},
                );

                # run module
                $Counter = $Object->Run(
                    %Param,
                    SLA     => \%SLA,
                    Counter => $Counter,
                    Config  => $Menus{$Menu},
                );
            }
            else {
                return $Self->{LayoutObject}->FatalError();
            }
        }
    }

    if ( $SLA{ServiceIDs} && ref $SLA{ServiceIDs} eq 'ARRAY' && @{ $SLA{ServiceIDs} } ) {

        # output row
        $Self->{LayoutObject}->Block(
            Name => 'Service',
        );

        # create service list
        my %ServiceList;
        for my $ServiceID ( @{ $SLA{ServiceIDs} } ) {

            # get service data
            my %Service = $Self->{ServiceObject}->ServiceGet(
                ServiceID => $ServiceID,
                UserID    => $Self->{UserID},
            );

            # add service to hash
            $ServiceList{$ServiceID} = \%Service;
        }

        # set incident signal
        my %InciSignals = (
            operational => 'greenled',
            warning     => 'yellowled',
            incident    => 'redled',
        );

        my $CssClass = '';
        for my $ServiceID (
            sort { $ServiceList{$a}->{Name} cmp $ServiceList{$b}->{Name} }
            keys %ServiceList
            )
        {

            # set output object
            $CssClass = $CssClass eq 'searchpassive' ? 'searchactive' : 'searchpassive';

            # output row
            $Self->{LayoutObject}->Block(
                Name => 'ServiceRow',
                Data => {
                    %{ $ServiceList{$ServiceID} },
                    CurInciSignal => $InciSignals{ $ServiceList{$ServiceID}->{CurInciStateType} },
                    CssClass      => $CssClass,
                },
            );
        }
    }

    # get create user data
    my %CreateUser = $Self->{UserObject}->GetUserData(
        UserID => $SLA{CreateBy},
        Cached => 1,
    );
    for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
        $SLA{ 'Create' . $Postfix } = $CreateUser{$Postfix};
    }

    # get change user data
    my %ChangeUser = $Self->{UserObject}->GetUserData(
        UserID => $SLA{ChangeBy},
        Cached => 1,
    );
    for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
        $SLA{ 'Change' . $Postfix } = $ChangeUser{$Postfix};
    }

    # output header
    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();

    # generate output
    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentITSMSLAZoom',
        Data         => {
            %Param,
            %SLA,
        },
    );
    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

1;